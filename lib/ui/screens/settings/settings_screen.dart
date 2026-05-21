import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(
            title: 'Cài đặt',
            centerTitle: true,
            showBackButton: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('HỌC TẬP'),
                  _buildSettingItem(
                    icon: Boxicons.bx_bell,
                    iconColor: Colors.blue,
                    title: 'Nhắc nhở học tập hàng ngày',
                    trailing: Switch(
                      value: true,
                      onChanged: (val) {},
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Boxicons.bx_volume_full,
                    iconColor: Colors.green,
                    title: 'Tự động phát phát âm từ vựng',
                    trailing: Switch(
                      value: true,
                      onChanged: (val) {},
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('ỨNG DỤNG'),
                  _buildSettingItem(
                    icon: Boxicons.bx_moon,
                    iconColor: Colors.purple,
                    title: 'Giao diện tối (Dark mode)',
                    subtitle: 'Đang phát triển...',
                    trailing: const Icon(Boxicons.bx_chevron_right, color: Colors.grey, size: 20),
                  ),
                  _buildSettingItem(
                    icon: Boxicons.bx_shield,
                    iconColor: Colors.teal,
                    title: 'Điều khoản & Chính sách bảo mật',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  // Nút Đăng xuất
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        _showLogoutConfirmDialog(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Boxicons.bx_log_out, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Đăng xuất tài khoản',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            )
          : null,
        trailing: trailing ?? const Icon(Boxicons.bx_chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('⚠️ Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản của mình không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                context.read<UserProvider>().clear();
                await AuthService().signOut();
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

// Helper extension to make standard buttons look premium
extension ElevatedButtonExt on ElevatedButton {
  Widget button({required VoidCallback onPressed, required Widget child}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}
