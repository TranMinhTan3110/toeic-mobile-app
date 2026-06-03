import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback? onForgotPassword;
  final String? Function(String?)? emailValidator;
  final String? Function(String?)? passwordValidator;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onLogin,
    this.onForgotPassword,
    this.emailValidator,
    this.passwordValidator,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryLighter.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đăng nhập',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chào mừng bạn quay lại!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),

          // Email field
          _buildLabel('Email'),
          const SizedBox(height: 8),
          _buildTextField(
            key: _emailFieldKey,
            controller: widget.emailController,
            hint: 'email@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: widget.emailValidator,
          ),
          const SizedBox(height: 6),
          if (_emailFieldKey.currentState?.errorText != null)
            Text(
              _emailFieldKey.currentState!.errorText!,
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          const SizedBox(height: 14),

          // Password field
          _buildLabel('Mật khẩu'),
          const SizedBox(height: 8),
          _buildTextField(
            key: _passwordFieldKey,
            controller: widget.passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: widget.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                widget.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: widget.onToggleObscure,
            ),
            validator: widget.passwordValidator,
          ),
          const SizedBox(height: 6),
          if (_passwordFieldKey.currentState?.errorText != null)
            Text(
              _passwordFieldKey.currentState!.errorText!,
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),

          const SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextFormField(
        key: key as GlobalKey<FormFieldState<String>>?,
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
          suffixIcon: suffixIcon,
          // hide default error text inside field
          errorStyle: const TextStyle(height: 0, fontSize: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}
