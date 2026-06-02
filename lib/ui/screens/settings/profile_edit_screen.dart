import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/core/services/auth_service.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/data/models/user_profile_model.dart';
import 'package:toeicmobileapp/providers/user_provider.dart';
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

  String? _selectedGender;
  bool _seeded = false;

  static const _genderOptions = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<UserProvider>();
      if (provider.profile == null) {
        provider.fetchProfile(forceRefresh: true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.watch<UserProvider>().profile;
    if (!_seeded && profile != null) {
      _seedForm(profile);
      _seeded = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = provider.profile;
    final effectiveProfile = profile ?? _profileFromAuth();
    if (!_seeded && effectiveProfile != null) {
      _seedForm(effectiveProfile);
      _seeded = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Chỉnh sửa hồ sơ', centerTitle: true),
      body: SafeArea(
        child: effectiveProfile == null && provider.isLoadingProfile
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : effectiveProfile == null
            ? _buildEmptyState(provider.profileError)
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProfileCard(effectiveProfile),
                            const SizedBox(height: 14),
                            _buildInfoCard(),
                            const SizedBox(height: 14),
                            _buildAccountCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomBar(provider.isLoadingProfile),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Boxicons.bx_user_x,
              size: 58,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            Text(
              error ?? 'Không thể tải hồ sơ cá nhân.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<UserProvider>().fetchProfile(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfileModel profile) {
    final initial = _initial(profile.displayName);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 33,
              backgroundColor: AppColors.primaryLight,
              backgroundImage:
                  profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName
                      : 'Học viên TOEIC',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Hồ sơ cá nhân',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _CardSection(
      title: 'Thông tin cá nhân',
      child: Column(
        children: [
          _buildField(
            controller: _nameCtrl,
            label: 'Họ và tên',
            hint: 'Nhập tên hiển thị',
            icon: Boxicons.bx_user,
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'Vui lòng nhập họ và tên';
              if (name.length > 100) return 'Tên không được vượt quá 100 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'email@example.com',
            icon: Boxicons.bx_envelope,
            enabled: false,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _phoneCtrl,
            label: 'Số điện thoại',
            hint: '0123 456 789',
            icon: Boxicons.bx_phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              final phone = value?.trim() ?? '';
              if (phone.isEmpty) return null;
              final valid = RegExp(r'^[0-9+\-\s().]{8,20}$').hasMatch(phone);
              return valid ? null : 'Số điện thoại chưa đúng định dạng';
            },
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _dobCtrl,
            label: 'Ngày sinh',
            hint: 'yyyy-MM-dd',
            icon: Boxicons.bx_calendar,
            readOnly: true,
            suffixIcon: Icons.calendar_month_rounded,
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: 16),
          _buildGenderPicker(),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return _CardSection(
      title: 'Tài khoản',
      child: Column(
        children: [
          _AccountAction(
            icon: Boxicons.bx_lock_alt,
            title: 'Đổi mật khẩu',
            color: AppColors.blue,
            background: AppColors.blueBg,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.divider),
          _AccountAction(
            icon: Boxicons.bx_trash,
            title: 'Xóa tài khoản',
            color: AppColors.error,
            background: AppColors.answerWrong,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _genderOptions.map((gender) {
            final selected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: gender == _genderOptions.last ? 0 : 8,
                ),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(gender, textAlign: TextAlign.center),
                  ),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.primarySurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedGender = gender),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    bool readOnly = false,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? Function(String?)? validator,
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
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.textSecondary)
                : null,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
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

  Widget _buildBottomBar(bool isSaving) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: isSaving ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Lưu thay đổi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_dobCtrl.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dobCtrl.text = _formatDate(picked));
    }
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await context.read<UserProvider>().updateProfile(
        displayName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        birthDate: _dobCtrl.text.trim(),
        gender: _selectedGender,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật hồ sơ thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final message = _cleanErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  void _seedForm(UserProfileModel profile) {
    _nameCtrl.text = profile.displayName;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phoneNumber ?? '';
    _dobCtrl.text = profile.birthDate ?? '';
    _selectedGender = _normalizeGender(profile.gender);
  }

  UserProfileModel? _profileFromAuth() {
    final authUser = AuthService().currentUser;
    if (authUser == null) return null;

    return UserProfileModel(
      uid: authUser.uid,
      displayName: authUser.displayName?.trim().isNotEmpty == true
          ? authUser.displayName!.trim()
          : 'Học viên TOEIC',
      email: authUser.email ?? '',
      avatarUrl: authUser.photoURL,
      targetScore: 0,
      currentLevel: 'beginner',
      plan: 'free',
      preferredSkills: const [],
      experiencePoints: 0,
      weeklyEp: 0,
      weeklyEpPeriodKey: '',
      streakDays: 0,
      bestStreakDays: 0,
      totalStudyMinutes: 0,
      createdAt: DateTime.now(),
    );
  }

  String _initial(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'U';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String? _normalizeGender(String? value) {
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (lower == 'male' || lower == 'nam') return 'Nam';
    if (lower == 'female' || lower == 'nữ' || lower == 'nu') return 'Nữ';
    return _genderOptions.contains(value) ? value : 'Khác';
  }

  String _cleanErrorMessage(Object error) {
    var message = error.toString();
    while (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    return message;
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.tabInactive),
          ],
        ),
      ),
    );
  }
}
