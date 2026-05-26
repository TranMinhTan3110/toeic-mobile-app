import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/ui/widgets/common/custom_app_bar.dart';
import 'package:toeicmobileapp/providers/user_provider.dart';
import 'package:toeicmobileapp/core/services/auth_service.dart';
import '../../widgets/settings/profile_header.dart';
import '../../widgets/settings/setting_tile.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.avatarUrl,
  });

  final bool isLoggedIn;
  final String? userName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final bool resolvedIsLoggedIn = profile != null;
    final String? resolvedUserName = profile?.displayName;
    final String? resolvedAvatarUrl = profile?.avatarUrl;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Cài đặt', centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(
              isLoggedIn: resolvedIsLoggedIn,
              userName: resolvedUserName,
              avatarUrl: resolvedAvatarUrl,
              onLogout: () async {
                // Thực hiện đăng xuất
                await AuthService().signOut();
                if (context.mounted) {
                  context.read<UserProvider>().clear();
                }
              },
            ),

            const Divider(height: 1, thickness: 1, color: AppColors.divider),

            const SizedBox(height: 8),

            SettingTile(
              icon: Icons.edit,
              title: 'Chỉnh sửa hồ sơ',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                );
              },
            ),

            SettingTile(
              icon: Icons.menu_book_rounded,
              title: 'Hướng dẫn sử dụng Migii hiệu quả',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.public,
              title: 'Ngôn ngữ ứng dụng',
              trailingText: 'Tiếng Việt',
              trailingTextColor: AppColors.textLink,
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Giao diện tối',
              trailingWidget: _DarkModeSwitch(),
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.checkroom_outlined,
              title: 'Giao diện đáp án',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.display_settings_outlined,
              title: 'Hiển thị',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.people_alt_outlined,
              title: 'Tham gia cộng đồng Migii Toeic',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.share_outlined,
              title: 'Chia sẻ ứng dụng',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.download_outlined,
              title: 'Quản lý tải xuống',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.alarm_on_outlined,
              title: 'Nhắc nhở học tập',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.rate_review_outlined,
              title: 'Phản hồi & hỗ trợ',
              onTap: () {},
            ),

            SettingTile(
              icon: Icons.star_border,
              title: 'Đánh giá 5 sao',
              onTap: () {},
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _DarkModeSwitch extends StatefulWidget {
  @override
  State<_DarkModeSwitch> createState() => _DarkModeSwitchState();
}

class _DarkModeSwitchState extends State<_DarkModeSwitch> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: (v) => setState(() => value = v),
    );
  }
}
