import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RegisterFormWidget extends StatefulWidget {
	final TextEditingController nameController;
	final TextEditingController emailController;
	final TextEditingController passwordController;
	final TextEditingController confirmController;
	final bool obscurePassword;
	final bool obscureConfirm;
	final bool isLoading;
	final bool agreeTerms;
	final VoidCallback onTogglePassword;
	final VoidCallback onToggleConfirm;
	final VoidCallback onToggleAgree;
	final VoidCallback onRegister;
	final String? Function(String?)? nameValidator;
	final String? Function(String?)? emailValidator;
	final String? Function(String?)? passwordValidator;
	final String? Function(String?)? confirmValidator;

	const RegisterFormWidget({
		Key? key,
		required this.nameController,
		required this.emailController,
		required this.passwordController,
		required this.confirmController,
		required this.obscurePassword,
		required this.obscureConfirm,
		required this.isLoading,
		required this.agreeTerms,
		required this.onTogglePassword,
		required this.onToggleConfirm,
		required this.onToggleAgree,
		required this.onRegister,
		this.nameValidator,
		this.emailValidator,
		this.passwordValidator,
		this.confirmValidator,
	}) : super(key: key);

	@override
	State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
	final _nameKey = GlobalKey<FormFieldState<String>>();
	final _emailKey = GlobalKey<FormFieldState<String>>();
	final _passwordKey = GlobalKey<FormFieldState<String>>();
	final _confirmKey = GlobalKey<FormFieldState<String>>();

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(26),
			decoration: BoxDecoration(
				color: AppColors.surface,
				borderRadius: BorderRadius.circular(28),
				border: Border.all(
					color: AppColors.primaryLighter.withOpacity(0.5),
				),
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
					_buildLabel('Họ và tên'),
					const SizedBox(height: 8),
					_buildTextField(
						key: _nameKey,
						controller: widget.nameController,
						hint: 'Nhập họ và tên',
						icon: Icons.person_outline_rounded,
						validator: widget.nameValidator,
					),
					const SizedBox(height: 6),
					if (_nameKey.currentState?.errorText != null)
						Text(_nameKey.currentState!.errorText!, style: TextStyle(color: AppColors.error, fontSize: 12)),
					const SizedBox(height: 12),

					_buildLabel('Email'),
					const SizedBox(height: 8),
					_buildTextField(
						key: _emailKey,
						controller: widget.emailController,
						hint: 'email@example.com',
						icon: Icons.email_outlined,
						keyboardType: TextInputType.emailAddress,
						validator: widget.emailValidator,
					),
					const SizedBox(height: 6),
					if (_emailKey.currentState?.errorText != null)
						Text(_emailKey.currentState!.errorText!, style: TextStyle(color: AppColors.error, fontSize: 12)),
					const SizedBox(height: 12),

					_buildLabel('Mật khẩu'),
					const SizedBox(height: 8),
					_buildTextField(
						key: _passwordKey,
						controller: widget.passwordController,
						hint: 'Tối thiểu 8 ký tự',
						icon: Icons.lock_outline_rounded,
						obscure: widget.obscurePassword,
						suffixIcon: IconButton(
							icon: Icon(widget.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint, size: 20),
							onPressed: widget.onTogglePassword,
						),
						validator: widget.passwordValidator,
					),
					const SizedBox(height: 6),
					if (_passwordKey.currentState?.errorText != null)
						Text(_passwordKey.currentState!.errorText!, style: TextStyle(color: AppColors.error, fontSize: 12)),

					const SizedBox(height: 12),
					_buildPasswordStrength(widget.passwordController.text),
					const SizedBox(height: 18),

					_buildLabel('Xác nhận mật khẩu'),
					const SizedBox(height: 8),
					_buildTextField(
						key: _confirmKey,
						controller: widget.confirmController,
						hint: 'Nhập lại mật khẩu',
						icon: Icons.lock_outline_rounded,
						obscure: widget.obscureConfirm,
						suffixIcon: IconButton(
							icon: Icon(widget.obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint, size: 20),
							onPressed: widget.onToggleConfirm,
						),
						validator: widget.confirmValidator,
					),
					const SizedBox(height: 6),
					if (_confirmKey.currentState?.errorText != null)
						Text(_confirmKey.currentState!.errorText!, style: TextStyle(color: AppColors.error, fontSize: 12)),

					const SizedBox(height: 22),

					GestureDetector(
						onTap: widget.onToggleAgree,
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								AnimatedContainer(
									duration: const Duration(milliseconds: 200),
									width: 20,
									height: 20,
									decoration: BoxDecoration(
										color: widget.agreeTerms ? AppColors.primary : Colors.transparent,
										borderRadius: BorderRadius.circular(6),
										border: Border.all(color: AppColors.primaryLighter),
									),
									child: widget.agreeTerms ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
								),
								const SizedBox(width: 12),
								Expanded(
									child: Text(
										'Tôi đồng ý với điều khoản dịch vụ và chính sách bảo mật',
										style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
									),
								),
							],
						),
					),

					const SizedBox(height: 28),

					SizedBox(
						width: double.infinity,
						height: 52,
						child: DecoratedBox(
							decoration: BoxDecoration(
								gradient: AppColors.primaryGradient,
								borderRadius: BorderRadius.circular(14),
								boxShadow: widget.agreeTerms
										? [
												BoxShadow(
													color: AppColors.primaryDark.withOpacity(0.35),
													blurRadius: 18,
													offset: const Offset(0, 6),
												)
											]
										: [],
							),
							child: ElevatedButton(
								onPressed: (widget.isLoading || !widget.agreeTerms) ? null : widget.onRegister,
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.transparent,
									shadowColor: Colors.transparent,
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
								),
								child: widget.isLoading
										? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
										: const Text('Tạo tài khoản', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildLabel(String text) {
		return Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3));
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
			decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.transparent)),
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
					contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
				),
			),
		);
	}

	Widget _buildPasswordStrength(String password) {
		int strength = 0;
		if (password.length >= 8) strength++;
		if (password.contains(RegExp(r'[A-Z]'))) strength++;
		if (password.contains(RegExp(r'[0-9]'))) strength++;
		if (password.contains(RegExp(r'[!@#\$&*~]'))) strength++;

		final labels = ['', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'];
		final colors = [Colors.transparent, AppColors.error, AppColors.warning, AppColors.success.withOpacity(0.9), AppColors.success];

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Row(
					children: List.generate(4, (i) {
						return Expanded(
							child: Container(
								height: 4,
								margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
								decoration: BoxDecoration(color: i < strength ? colors[strength] : AppColors.primaryLighter, borderRadius: BorderRadius.circular(2)),
							),
						);
					}),
				),
				if (password.isNotEmpty) ...[
					const SizedBox(height: 6),
					Text('Độ mạnh: ${labels[strength]}', style: TextStyle(color: colors[strength].withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500)),
				],
			],
		);
	}
}


