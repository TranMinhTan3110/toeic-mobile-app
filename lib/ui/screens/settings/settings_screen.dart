import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:toeicmobileapp/core/services/auth_service.dart';
import 'package:toeicmobileapp/core/services/study_reminder_service.dart';
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
                  const _StudyReminderTile(),
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

class _StudyReminderTile extends StatefulWidget {
  const _StudyReminderTile();

  @override
  State<_StudyReminderTile> createState() => _StudyReminderTileState();
}

class _StudyReminderTileState extends State<_StudyReminderTile> {
  StudyReminderSettings _settings = const StudyReminderSettings(
    enabled: false,
    hour: 19,
    minute: 0,
  );
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _settings.enabled
        ? 'Hằng ngày lúc ${_settings.formattedTime}'
        : 'Chưa bật nhắc nhở';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loading || _saving ? null : _pickTime,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Boxicons.bx_bell,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhắc nhở học tập',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TimePill(
                time: _settings.formattedTime,
                enabled: !_loading && !_saving,
                onTap: _pickTime,
              ),
              const SizedBox(width: 8),
              Switch(
                value: _settings.enabled,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryLight,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.divider,
                onChanged: _loading || _saving ? null : _toggleReminder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSettings() async {
    final settings = await StudyReminderService.instance.getSettings();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _settings.hour, minute: _settings.minute),
      helpText: 'Chọn giờ nhắc học',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    await _saveReminder(
      enabled: _settings.enabled,
      hour: picked.hour,
      minute: picked.minute,
    );
  }

  Future<void> _toggleReminder(bool enabled) async {
    await _saveReminder(
      enabled: enabled,
      hour: _settings.hour,
      minute: _settings.minute,
    );
  }

  Future<void> _saveReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    setState(() => _saving = true);

    final saved = await StudyReminderService.instance.setDailyReminder(
      enabled: enabled,
      hour: hour,
      minute: minute,
    );

    if (!mounted) return;
    setState(() {
      if (saved) {
        _settings = StudyReminderSettings(
          enabled: enabled,
          hour: hour,
          minute: minute,
        );
      }
      _saving = false;
    });

    if (!saved) {
      _showReminderMessage(
        'Không thể bật thông báo. Hãy cấp quyền thông báo trên thiết bị.',
        AppColors.error,
      );
      return;
    }

    _showReminderMessage(
      enabled
          ? 'Đã bật nhắc nhở lúc ${_settings.formattedTime}.'
          : 'Đã tắt nhắc nhở học tập.',
      enabled ? AppColors.success : AppColors.textSecondary,
    );
  }

  void _showReminderMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.time,
    required this.enabled,
    required this.onTap,
  });

  final String time;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minWidth: 62),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textLink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
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
