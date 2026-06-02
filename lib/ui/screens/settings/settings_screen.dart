import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:toeicmobileapp/core/services/auth_service.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/providers/grammar_provider.dart';
import 'package:toeicmobileapp/providers/listening_provider.dart';
import 'package:toeicmobileapp/providers/user_provider.dart';
import 'package:toeicmobileapp/ui/shared/practice_dialogs.dart';
import 'package:toeicmobileapp/ui/widgets/common/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/settings/profile_header.dart';
import '../../widgets/settings/setting_tile.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.avatarUrl,
    this.onBack,
  });

  final bool isLoggedIn;
  final String? userName;
  final String? avatarUrl;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final authUser = AuthService().currentUser;
    final resolvedUserName = profile?.displayName.trim().isNotEmpty == true
        ? profile!.displayName
        : authUser?.displayName;
    final resolvedEmail = profile?.email.trim().isNotEmpty == true
        ? profile!.email
        : authUser?.email;
    final resolvedAvatarUrl = profile?.avatarUrl?.trim().isNotEmpty == true
        ? profile!.avatarUrl
        : authUser?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Cài đặt', centerTitle: true, onBack: onBack),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            context.read<UserProvider>().fetchProfile(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                isLoggedIn: true,
                userName: resolvedUserName,
                email: resolvedEmail,
                avatarUrl: resolvedAvatarUrl,
                onLogout: () => _logout(context),
              ),
              _SettingsSection(
                title: 'Tài khoản',
                children: [
                  SettingTile(
                    icon: Boxicons.bx_user,
                    title: 'Chỉnh sửa hồ sơ',
                    subtitle: 'Tên, số điện thoại, ngày sinh',
                    iconColor: AppColors.primary,
                    iconBackground: AppColors.primaryPale,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileEditScreen(),
                        ),
                      );
                    },
                  ),
                  SettingTile(
                    icon: Boxicons.bx_lock_alt,
                    title: 'Bảo mật tài khoản',
                    subtitle: 'Đổi mật khẩu và thiết lập đăng nhập',
                    iconColor: AppColors.blue,
                    iconBackground: AppColors.blueBg,
                    onTap: () {},
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Học tập',
                children: [
                  SettingTile(
                    icon: Boxicons.bx_book_open,
                    title: 'Hướng dẫn học TOEIC hiệu quả',
                    iconColor: AppColors.green,
                    iconBackground: AppColors.greenBg,
                    onTap: () {},
                  ),
                  SettingTile(
                    icon: Boxicons.bx_bell,
                    title: 'Nhắc nhở học tập',
                    trailingText: 'Tắt',
                    trailingTextColor: AppColors.textSecondary,
                    iconColor: AppColors.warning,
                    iconBackground: AppColors.primarySurface,
                    onTap: () => _showStudyReminderDialog(context),
                  ),
                  SettingTile(
                    icon: Boxicons.bx_download,
                    title: 'Quản lý tải xuống',
                    iconColor: AppColors.purple,
                    iconBackground: AppColors.purpleBg,
                    onTap: () {},
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Giao diện',
                children: [
                  SettingTile(
                    icon: Boxicons.bx_globe,
                    title: 'Ngôn ngữ ứng dụng',
                    trailingText: 'Tiếng Việt',
                    trailingTextColor: AppColors.textLink,
                    iconColor: AppColors.blue,
                    iconBackground: AppColors.blueBg,
                    onTap: () {},
                  ),
                  SettingTile(
                    icon: Boxicons.bx_moon,
                    title: 'Giao diện tối',
                    trailingWidget: _DarkModeSwitch(),
                    showChevron: false,
                    iconColor: AppColors.textSecondary,
                    iconBackground: AppColors.surfaceVariant,
                    onTap: () {},
                  ),
                  SettingTile(
                    icon: Boxicons.bx_customize,
                    title: 'Hiển thị đáp án',
                    subtitle: 'Tùy chỉnh cách hiện đáp án khi luyện tập',
                    iconColor: AppColors.primary,
                    iconBackground: AppColors.primaryPale,
                    onTap: () {},
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Cộng đồng',
                children: [
                  SettingTile(
                    icon: Boxicons.bx_group,
                    title: 'Tham gia cộng đồng TOEIC Master',
                    iconColor: AppColors.green,
                    iconBackground: AppColors.greenBg,
                    onTap: () {},
                  ),
                  SettingTile(
                    icon: Boxicons.bx_share_alt,
                    title: 'Chia sẻ ứng dụng',
                    iconColor: AppColors.blue,
                    iconBackground: AppColors.blueBg,
                    onTap: () {},
                  ),
                  SettingTile(
                    icon: Boxicons.bx_support,
                    title: 'Phản hồi & hỗ trợ',
                    iconColor: AppColors.purple,
                    iconBackground: AppColors.purpleBg,
                    onTap: () => _showSupportDialog(context, resolvedEmail),
                  ),
                  SettingTile(
                    icon: Boxicons.bx_star,
                    title: 'Đánh giá 5 sao',
                    iconColor: AppColors.star,
                    iconBackground: AppColors.primarySurface,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showPremiumConfirmDialog(
      context,
      title: 'Đăng xuất?',
      text: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      icon: Boxicons.bx_log_out,
    );
    if (confirm && context.mounted) {
      final userProvider = context.read<UserProvider>();
      final grammarProvider = context.read<GrammarProvider>();
      final listeningProvider = context.read<ListeningProvider>();
      await AuthService().signOut();
      userProvider.clear();
      grammarProvider.clearCache();
      listeningProvider.clearCache();
    }
  }

  Future<void> _showStudyReminderDialog(BuildContext context) async {
    var enabled = false;
    var selectedTime = '19:00';
    final selectedDays = <String>{'T2', 'T4', 'T6'};
    const timeOptions = ['07:00', '12:00', '19:00', '21:00'];
    const dayOptions = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Boxicons.bx_bell,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nhắc nhở học tập',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Chọn thời điểm TOEIC Master nhắc bạn học.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Bật nhắc nhở',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Switch(
                            value: enabled,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primaryLight,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: AppColors.divider,
                            onChanged: (value) {
                              setDialogState(() => enabled = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ReminderSectionTitle(title: 'Giờ nhắc'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeOptions.map((time) {
                        final selected = selectedTime == time;
                        return _ReminderChoiceChip(
                          label: time,
                          selected: selected,
                          onTap: () {
                            setDialogState(() => selectedTime = time);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const _ReminderSectionTitle(title: 'Ngày học'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dayOptions.map((day) {
                        final selected = selectedDays.contains(day);
                        return _ReminderChoiceChip(
                          label: day,
                          selected: selected,
                          minWidth: 46,
                          onTap: () {
                            setDialogState(() {
                              if (selected) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    enabled
                                        ? 'Đã lưu nhắc nhở lúc $selectedTime.'
                                        : 'Đã tắt nhắc nhở học tập.',
                                  ),
                                  backgroundColor: enabled
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Lưu',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSupportDialog(
    BuildContext context,
    String? senderEmail,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.purpleBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Boxicons.bx_support,
                        color: AppColors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phản hồi & hỗ trợ',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Chọn cách gửi phản hồi cho chúng mình nhé.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SupportChoiceButton(
                        icon: Boxicons.bxl_gmail,
                        iconColor: const Color(0xFFEA4335),
                        iconBackground: AppColors.answerWrong,
                        label: 'Gửi Email',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _openEmailSupport(context, senderEmail);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SupportChoiceButton(
                        icon: Boxicons.bxl_messenger,
                        iconColor: const Color(0xFF1D9BF0),
                        iconBackground: AppColors.blueBg,
                        label: 'Messenger',
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _openMessengerSupport(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEmailSupport(
    BuildContext context,
    String? senderEmail,
  ) async {
    const recipient = 'lengocbaochan3009@gmail.com';
    final sender = senderEmail?.trim().isNotEmpty == true
        ? senderEmail!.trim()
        : 'Chưa xác định';
    final subject = 'Phản hồi TOEIC Master';
    final body = 'Email người gửi: $sender\n\nNội dung phản hồi:\n';

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {'subject': subject, 'body': body},
    );

    final gmailWebUri = Uri.https('mail.google.com', '/mail/', {
      'view': 'cm',
      'fs': '1',
      'to': recipient,
      'su': subject,
      'body': body,
    });

    final opened = await _launchFirstAvailable([mailtoUri, gmailWebUri]);
    if (!opened && context.mounted) {
      _showSupportError(context, 'Không thể mở ứng dụng gửi email.');
    }
  }

  Future<void> _openMessengerSupport(BuildContext context) async {
    final messengerUri = Uri.https('m.me', '/chan.lengocbao.9');
    final facebookUri = Uri.parse('https://www.facebook.com/chan.lengocbao.9');

    final opened = await _launchFirstAvailable([messengerUri, facebookUri]);
    if (!opened && context.mounted) {
      _showSupportError(context, 'Không thể mở Messenger.');
    }
  }

  Future<bool> _launchFirstAvailable(List<Uri> uris) async {
    for (final uri in uris) {
      try {
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (opened) return true;
      } catch (_) {
        // Try the next fallback URI.
      }
    }
    return false;
  }

  void _showSupportError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

class _ReminderSectionTitle extends StatelessWidget {
  const _ReminderSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ReminderChoiceChip extends StatelessWidget {
  const _ReminderChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.minWidth = 68,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SupportChoiceButton extends StatelessWidget {
  const _SupportChoiceButton({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(children: children),
            ),
          ),
        ],
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
      activeTrackColor: AppColors.primaryLight,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AppColors.divider,
      onChanged: (v) => setState(() => value = v),
    );
  }
}
