import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/ui/widgets/common/custom_app_bar.dart';
import 'change_password_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Thông tin người dùng', centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tên', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildField(controller: _nameCtrl, hint: 'Họ và tên'),

                      const SizedBox(height: 16),
                      const Text('Email', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildField(controller: _emailCtrl, hint: 'email@example.com'),

                      const SizedBox(height: 16),
                      const Text('Số điện thoại', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildField(controller: _phoneCtrl, hint: '0123 456 789'),

                      const SizedBox(height: 16),
                      const Text('Ngày sinh', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildField(controller: _dobCtrl, hint: 'dd/mm/yyyy'),

                      const SizedBox(height: 16),
                      const Text('Giới tính', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildField(controller: _genderCtrl, hint: 'Nam / Nữ'),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Chỉnh sửa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Change password link (underlined)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                        );
                      },
                      child: Text(
                        'Đổi mật khẩu',
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Delete account (red)
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Xóa tài khoản',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, String? hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.badgeBg.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? true) {
      // TODO: save profile data to backend / state
      Navigator.of(context).pop();
    }
  }
}
