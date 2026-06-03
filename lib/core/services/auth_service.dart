import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Khởi tạo GoogleSignIn kèm Client ID cho Web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '179821265499-mmqn90k4g7krlvfdjtls9oovn43tj7vk.apps.googleusercontent.com'
        : null,
  );

  final Dio _dio = Dio();

  // Stream lắng nghe trạng thái đăng nhập (đã đăng nhập / chưa đăng nhập)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy User hiện tại
  User? get currentUser => _auth.currentUser;

  // 1. Đăng nhập bằng Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Trên Web: Sử dụng trực tiếp GoogleAuthProvider của Firebase (Ổn định nhất)
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        authProvider.setCustomParameters({'prompt': 'select_account'});
        UserCredential result = await _auth.signInWithPopup(authProvider);
        if (result.user != null) {
          await _syncUserWithBackend(result.user!);
        }
        return result;
      } else {
        // Trên Mobile (Android/iOS): Sử dụng thư viện google_sign_in
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return null; // Người dùng hủy bỏ đăng nhập
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential result = await _auth.signInWithCredential(
          credential,
        );
        if (result.user != null) {
          await _syncUserWithBackend(result.user!);
        }
        return result;
      }
    } catch (e) {
      debugPrint("Lỗi đăng nhập Google: $e");
      rethrow;
    }
  }

  // 2. Đăng ký bằng Email / Password
  Future<UserCredential?> registerWithEmailPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        // ⚠️ Set displayName TRƯỚC khi sync backend
        // vì backend đọc claim "name" từ Firebase token
        // nếu sync trước thì claim chưa có → lưu thành "TOEIC User"
        if (displayName != null && displayName.isNotEmpty) {
          await result.user!.updateDisplayName(displayName);
          await result.user!.reload(); // Force refresh token claims
        }
        final currentUser = _auth.currentUser ?? result.user!;
        await _syncUserWithBackend(currentUser, forceRefresh: true);
      }
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint("Lỗi đăng ký Firebase: ${e.message}");
      rethrow;
    }
  }

  // 3. Đăng nhập bằng Email / Password
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        await _syncUserWithBackend(result.user!, forceRefresh: true);
      }
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint("Lỗi đăng nhập Firebase: ${e.message}");
      rethrow;
    }
  }

  // 4. Đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Lỗi đăng xuất: $e");
    }
  }

  // (Tuỳ chọn) Hàm reset mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Lỗi gửi email reset: $e");
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Bạn cần đăng nhập lại để đổi mật khẩu.',
      );
    }

    await _reauthenticateCurrentUser(user, password: currentPassword);
    await user.updatePassword(newPassword);
    await user.reload();
  }

  Future<void> deleteCurrentAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Bạn cần đăng nhập lại để xóa tài khoản.',
      );
    }

    await _reauthenticateCurrentUser(user, password: password);
    await _deleteProfileFromBackend(user);
    await user.delete();
    await _googleSignIn.signOut();
  }

  /// Lấy ID token hiện tại (dùng cho API Bearer / test Scalar).
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }

  Future<void> _reauthenticateCurrentUser(User user, {String? password}) async {
    final providerIds = user.providerData
        .map((info) => info.providerId)
        .toSet();

    if (providerIds.contains('password')) {
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'Tài khoản chưa có email để xác thực lại.',
        );
      }
      if (password == null || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-password',
          message: 'Vui lòng nhập mật khẩu hiện tại.',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (providerIds.contains('google.com')) {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        await user.reauthenticateWithPopup(provider);
        return;
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'reauth-cancelled',
          message: 'Bạn đã hủy xác thực Google.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    throw FirebaseAuthException(
      code: 'unsupported-provider',
      message: 'Phương thức đăng nhập này chưa hỗ trợ thao tác tài khoản.',
    );
  }

  Future<void> _deleteProfileFromBackend(User user) async {
    try {
      final idToken = await user.getIdToken(true);
      if (idToken == null) return;

      await _dio.delete(
        '${AppConstants.baseUrl}/Users/me',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
    } catch (e) {
      debugPrint("Lỗi khi xóa hồ sơ backend: $e");
    }
  }

  void _logIdTokenForApiTesting(String idToken, User user) {
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════╗');
    debugPrint('║  FIREBASE ID TOKEN — copy dán vào Scalar / Postman       ║');
    debugPrint('╚══════════════════════════════════════════════════════════╝');
    debugPrint('UID: ${user.uid}');
    debugPrint('Email: ${user.email}');
    debugPrint('--- TOKEN START ---');
    debugPrint(idToken);
    debugPrint('--- TOKEN END ---');
    debugPrint('Scalar sync body: { "token": "<paste above>" }');
    debugPrint('Các API khác: Authorization: Bearer <paste above>');
    debugPrint('');
  }

  // 5. Đồng bộ User với Backend
  Future<void> _syncUserWithBackend(
    User user, {
    bool forceRefresh = false,
  }) async {
    try {
      final String? idToken = await user.getIdToken(forceRefresh);
      if (idToken == null) return;

      _logIdTokenForApiTesting(idToken, user);

      final response = await _dio.post(
        '${AppConstants.baseUrl}/Auth/sync',
        data: {'token': idToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Đồng bộ User với Backend thành công!");
      } else {
        debugPrint("Đồng bộ User thất bại: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi khi gọi API đồng bộ User: $e");
    }
  }
}
