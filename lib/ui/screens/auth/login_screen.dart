import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toeicmobileapp/ui/shared/practice_dialogs.dart';
import 'package:toeicmobileapp/core/services/auth_service.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/core/utils/validators.dart';
import 'package:toeicmobileapp/ui/widgets/auth/login_form.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryDark.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // Logo & Title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryDark.withOpacity(0.15),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  'https://res.cloudinary.com/dlfc5qwhj/image/upload/q_auto/f_auto/v1780328432/Logo/logo-toeic_2.png',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.primary,
                                      child: const Icon(
                                        Icons.auto_stories_rounded,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'TOEIC Master',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Chinh phục TOEIC cùng AI',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 44),

                      // Card (extracted)
                      Form(
                        key: _formKey,
                        child: LoginFormWidget(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          isLoading: _isLoading,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onLogin: () {
                            final valid =
                                _formKey.currentState?.validate() ?? false;
                            setState(() {});
                            if (valid) {
                              _handleLogin();
                            }
                          },
                          onForgotPassword: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, _) =>
                                    const ForgotPasswordScreen(),
                                transitionsBuilder:
                                    (_, animation, _, child) {
                                      return SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              ),
                                            ),
                                        child: child,
                                      );
                                    },
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                              ),
                            );
                          },
                          emailValidator: (v) => Validators.email(v),
                          passwordValidator: (v) => Validators.password(v),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.primaryLighter),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'hoặc',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.primaryLighter),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google sign in
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFFFCC80)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            color: Color(0xFFEA4335),
                            size: 30,
                          ),
                          label: const Text(
                            'Tiếp tục với Google',
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Chưa có tài khoản? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, animation, _) =>
                                        const RegisterView(),
                                    transitionsBuilder:
                                        (_, animation, _, child) {
                                          return SlideTransition(
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(1, 0),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                            child: child,
                                          );
                                        },
                                    transitionDuration: const Duration(
                                      milliseconds: 400,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Vui lòng chờ...',
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // UI form helpers moved to separate widgets

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showPremiumWarningDialog(
        context,
        title: 'Thông báo',
        text: 'Vui lòng nhập đầy đủ Email và Mật khẩu',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailPassword(email, password);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = 'Email hoặc mật khẩu không chính xác.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Định dạng email không hợp lệ.';
      }

      if (mounted) {
        showPremiumErrorDialog(
          context,
          title: 'Đăng nhập thất bại',
          text: errorMessage,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        // User hủy bỏ đăng nhập
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('show_welcome_dialog', true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showPremiumErrorDialog(
          context,
          title: 'Đăng nhập thất bại',
          text: 'Đăng nhập Google thất bại!',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
