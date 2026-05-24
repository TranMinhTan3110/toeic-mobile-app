import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toeicmobileapp/ui/shared/practice_dialogs.dart';
import 'package:toeicmobileapp/core/services/auth_service.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/core/utils/validators.dart';
import 'package:toeicmobileapp/ui/widgets/auth/register_form.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeTerms = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primary.withOpacity(0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primaryDark.withOpacity(0.12), Colors.transparent],
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
                      const SizedBox(height: 10),

                      // Header
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tạo tài khoản',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Bắt đầu hành trình TOEIC của bạn',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Form card
                      Form(
                        key: _formKey,
                        child: RegisterFormWidget(
                          nameController: _nameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmController: _confirmController,
                          obscurePassword: _obscurePassword,
                          obscureConfirm: _obscureConfirm,
                          isLoading: _isLoading,
                          agreeTerms: _agreeTerms,
                          onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                          onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          onToggleAgree: () => setState(() => _agreeTerms = !_agreeTerms),
                          onRegister: () {
                            final valid = _formKey.currentState?.validate() ?? false;
                            setState(() {});
                            final agreedError = Validators.mustAgree(_agreeTerms);
                            if (!valid) return;
                            if (agreedError != null) {
                              showPremiumWarningDialog(
                                context,
                                title: 'Thông báo',
                                text: agreedError,
                              );
                              return;
                            }
                            _handleRegister();
                          },
                          nameValidator: (v) => Validators.name(v),
                          emailValidator: (v) => Validators.email(v),
                          passwordValidator: (v) => Validators.password(v),
                          confirmValidator: (v) => Validators.confirmPassword(v, _passwordController.text),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Hoặc đăng nhập với Google
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.primaryLighter, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Hoặc',
                              style: TextStyle(
                                color: AppColors.textHint.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.primaryLighter, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Nút Đăng nhập với Google
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: AppColors.primaryLighter),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFDB4437),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Đăng nhập với Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Đã có tài khoản? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Đăng nhập',
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

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final name = _nameController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showPremiumWarningDialog(
        context,
        title: 'Thông báo',
        text: 'Vui lòng điền đầy đủ thông tin',
      );
      return;
    }

    if (password != confirm) {
      showPremiumWarningDialog(
        context,
        title: 'Thông báo',
        text: 'Mật khẩu xác nhận không khớp',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCred = await _authService.registerWithEmailPassword(
        email,
        password,
        displayName: name,
      );
      
      if (mounted) {
        showPremiumSuccessDialog(
          context,
          title: 'Đăng ký thành công',
          text: 'Chúc mừng bạn đã gia nhập TOEIC Master! 🎉',
          onConfirm: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email này đã được sử dụng.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Định dạng email không hợp lệ.';
      }
      
      if (mounted) {
        showPremiumErrorDialog(
          context,
          title: 'Đăng ký thất bại',
          text: errorMessage,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) return;
      
      if (mounted) {
        showPremiumSuccessDialog(
          context,
          title: 'Đăng nhập thành công',
          text: 'Chào mừng bạn đến với TOEIC Master! 🎉',
          onConfirm: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showPremiumErrorDialog(
          context,
          title: 'Đăng nhập thất bại',
          text: 'Đăng nhập Google thất bại!',
        );
      }
    }
  }
}
