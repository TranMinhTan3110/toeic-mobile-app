import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../../data/models/user_profile_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../core/utils/level_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.fetchProfile();
    if (mounted) setState(() => _isInit = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final isLoading = userProvider.isLoadingProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Hồ sơ cá nhân',
              centerTitle: true,
              showBackButton: false,
            ),
            Expanded(
              child: isLoading && _isInit
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : profile == null
                  ? _buildEmptyOrErrorState(userProvider.profileError)
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(profile),
                          _buildStatsGrid(profile),
                          _buildLevelProgressBar(profile),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Boxicons.bx_user_x,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Không thể tải thông tin tài khoản.',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER HỒ SƠ PREMIUM ───────────────────────────────────────
  Widget _buildProfileHeader(UserProfileModel profile) {
    final int level = LevelHelper.levelFromEp(profile.experiencePoints);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar tròn với viền phát sáng
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _buildAvatar(
              profile.avatarUrl,
              profile.displayName,
              radius: 35,
            ),
          ),
          const SizedBox(width: 16),
          // Tên hiển thị và Danh hiệu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName
                      : 'Học viên TOEIC',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getBadgeName(level),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Nút chỉnh sửa nhanh
          GestureDetector(
            onTap: () => _showEditGoalsSheet(profile),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Boxicons.bx_edit_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBadgeName(int level) => LevelHelper.badgeName(level);

  /// Avatar có fallback chữ cái
  /// Trên Flutter Web dùng chữ cái luôn (Google photo bị CORS bỏ qua)
  Widget _buildAvatar(
    String? avatarUrl,
    String displayName, {
    double radius = 24,
  }) {
    final initial = displayName.isNotEmpty
        ? displayName.trimLeft()[0].toUpperCase()
        : 'U';
    final diameter = radius * 2;

    Widget fallback = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    // Web: CORS block → dùng fallback luôn
    if (kIsWeb || avatarUrl == null || avatarUrl.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        avatarUrl,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }

  // ── STATS GRID ───────────────────────────────────────────────
  Widget _buildStatsGrid(UserProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Boxicons.bxs_flame,
              iconColor: Colors.orange.shade700,
              bgColor: Colors.orange.shade50,
              value: '${profile.streakDays} ngày',
              label: 'Chuỗi Streak',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Boxicons.bxs_star,
              iconColor: Colors.purple.shade600,
              bgColor: Colors.purple.shade50,
              value: '${profile.experiencePoints}',
              label: 'Tổng điểm EP',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Boxicons.bx_target_lock,
              iconColor: Colors.blue.shade600,
              bgColor: Colors.blue.shade50,
              value: '${profile.targetScore}',
              label: 'Mục tiêu',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── LEVEL PROGRESS BAR ───────────────────────────────────────
  Widget _buildLevelProgressBar(UserProfileModel profile) {
    final int currentEp = profile.experiencePoints;
    final int level = LevelHelper.levelFromEp(currentEp);
    final int relativeEp = LevelHelper.epProgressInLevel(currentEp);
    final int required = LevelHelper.epRequiredForLevel(level);
    final int toNext = LevelHelper.epToNextLevel(currentEp);
    final double progress = LevelHelper.progressRatio(currentEp);
    final bool isMaxLevel = level >= LevelHelper.maxLevel;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Boxicons.bx_award,
                    color: Colors.yellow.shade800,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cấp độ $level${isMaxLevel ? " 👑 MAX" : ""}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                '$relativeEp / $required EP',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMaxLevel
                ? '🎉 Bạn đã đạt cấp độ tối đa! TOEIC Master!'
                : 'Học thêm $toNext EP nữa để thăng cấp ${level + 1}!',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── WEEKLY LEADERBOARD SECTION ─────────────────────────────────
  Widget _buildLeaderboardSection(
    List<dynamic> leaderboard,
    UserProfileModel currentUser,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề bảng xếp hạng
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Icon(Boxicons.bx_trophy, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Bảng Xếp Hạng Tuần',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          if (leaderboard.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Chưa có dữ liệu bảng xếp hạng tuần này.\nBắt đầu học ngay để dẫn đầu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final isMe = entry.uid == currentUser.uid;

                return Container(
                  color: isMe
                      ? AppColors.primaryPale.withOpacity(0.4)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Thứ hạng
                      _buildRankBadge(entry.rank),
                      const SizedBox(width: 12),
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isMe
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        backgroundImage:
                            entry.avatarUrl != null &&
                                entry.avatarUrl.isNotEmpty
                            ? NetworkImage(entry.avatarUrl)
                            : null,
                        child:
                            entry.avatarUrl == null || entry.avatarUrl.isEmpty
                            ? Text(
                                entry.displayName.isNotEmpty
                                    ? entry.displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Tên hiển thị
                      Expanded(
                        child: Text(
                          entry.displayName.isNotEmpty
                              ? entry.displayName
                              : 'Học viên ẩn danh',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isMe
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isMe
                                ? AppColors.primaryDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Streak
                      Row(
                        children: [
                          const Icon(
                            Boxicons.bxs_flame,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${entry.streakDays}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Điểm EP Tuần
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.weeklyEp} EP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isMe ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: Icon(Boxicons.bx_crown, color: Colors.amber, size: 22),
        ),
      );
    }
    if (rank == 2) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            '2',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }
    if (rank == 3) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.orange.shade300,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            '3',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: 22,
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── BOTTOM SHEET CHỈNH SỬA MỤC TIÊU ───────────────────────────────
  void _showEditGoalsSheet(UserProfileModel profile) {
    int selectedScore = profile.targetScore == 0 ? 550 : profile.targetScore;
    String selectedLevel = profile.currentLevel.isEmpty
        ? 'Beginner'
        : profile.currentLevel;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 Chỉnh sửa mục tiêu học tập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Chọn Điểm mục tiêu
                  const Text(
                    'Chọn điểm TOEIC mục tiêu:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [450, 600, 750, 900].map((score) {
                      final isSelected = selectedScore == score;
                      return ChoiceChip(
                        label: Text('$score+'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedScore = score;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Chọn Trình độ
                  const Text(
                    'Trình độ tiếng Anh hiện tại:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Beginner', 'Intermediate', 'Advanced'].map((
                      lvl,
                    ) {
                      final isSelected = selectedLevel == lvl;
                      return ChoiceChip(
                        label: Text(
                          lvl == 'Beginner'
                              ? 'Cơ bản'
                              : lvl == 'Intermediate'
                              ? 'Trung cấp'
                              : 'Nâng cao',
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedLevel = lvl;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  // Nút Lưu
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        // Show loading snackbar
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(width: 16),
                                Text('Đang lưu thay đổi...'),
                              ],
                            ),
                            duration: Duration(
                              days: 1,
                            ), // infinite until manually closed
                          ),
                        );
                        try {
                          await this.context.read<UserProvider>().updateProfile(
                            targetScore: selectedScore,
                            currentLevel: selectedLevel,
                            preferredSkills: profile.preferredSkills,
                          );
                          ScaffoldMessenger.of(this.context).clearSnackBars();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Cập nhật mục tiêu học tập thành công! 🎉',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(this.context).clearSnackBars();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
