import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:toeicmobileapp/core/services/auth_service.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/ui/widgets/common/custom_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSaving = false;
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Đổi mật khẩu', centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                          controller: _currentCtrl,
                          label: 'Mật khẩu hiện tại',
                          icon: Boxicons.bx_lock_alt,
                          obscureText: _hideCurrent,
                          onToggleVisibility: () {
                            setState(() => _hideCurrent = !_hideCurrent);
                          },
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Vui lòng nhập mật khẩu hiện tại';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _newCtrl,
                          label: 'Mật khẩu mới',
                          icon: Boxicons.bx_key,
                          obscureText: _hideNew,
                          onToggleVisibility: () {
                            setState(() => _hideNew = !_hideNew);
                          },
                          validator: (value) {
                            final password = value ?? '';
                            if (password.length < 6) {
                              return 'Mật khẩu mới cần ít nhất 6 ký tự';
                            }
                            if (password == _currentCtrl.text) {
                              return 'Mật khẩu mới phải khác mật khẩu hiện tại';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _confirmCtrl,
                          label: 'Xác nhận mật khẩu',
                          icon: Boxicons.bx_check_shield,
                          obscureText: _hideConfirm,
                          onToggleVisibility: () {
                            setState(() => _hideConfirm = !_hideConfirm);
                          },
                          validator: (value) {
                            if (value != _newCtrl.text) {
                              return 'Mật khẩu xác nhận chưa khớp';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 21),
            suffixIcon: IconButton(
              tooltip: obscureText ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Boxicons.bx_hide : Boxicons.bx_show,
                color: AppColors.textSecondary,
                size: 21,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Lưu mật khẩu',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await AuthService().changePassword(
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_firebaseErrorMessage(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu hiện tại không đúng.';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu, vui lòng chọn mật khẩu khác.';
      case 'requires-recent-login':
        return 'Phiên đăng nhập đã cũ, vui lòng đăng nhập lại rồi thử tiếp.';
      case 'network-request-failed':
        return 'Không có kết nối mạng, vui lòng thử lại.';
      default:
        return error.message ?? 'Không thể đổi mật khẩu.';
    }
  }

  String _cleanErrorMessage(Object error) {
    var message = error.toString();
    while (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    return message;
  }
}
