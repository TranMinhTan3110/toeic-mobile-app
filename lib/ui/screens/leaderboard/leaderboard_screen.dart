import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/level_helper.dart';
import '../../../providers/user_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final leaderboard = userProvider.leaderboard;
          final currentUser = userProvider.profile;
          final isLoading = userProvider.isLoadingLeaderboard;

          final top3 = leaderboard.take(3).toList();
          final rest = leaderboard.skip(3).toList();

          return Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              _buildHeader(),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : leaderboard.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: () => userProvider.fetchLeaderboard(),
                        color: AppColors.primary,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            // Podium
                            if (top3.isNotEmpty) _buildPodium(top3),
                            const SizedBox(height: 16),

                            // Divider
                            if (rest.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: AppColors.divider),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'Bảng xếp hạng đầy đủ',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: AppColors.divider),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...rest.map(
                                (e) => _buildListItem(
                                  entry: e,
                                  isMe: currentUser?.uid == e.uid,
                                ),
                              ),
                            ],

                            // Nếu user không có trong list
                            if (currentUser != null &&
                                !leaderboard.any(
                                  (l) => l.uid == currentUser.uid,
                                ))
                              _buildMyPositionCard(currentUser),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header cam gradient ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Boxicons.bx_trophy, color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bảng Xếp Hạng Tuần',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Reset mỗi thứ 2 · EP tuần này',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Podium Top 3 ─────────────────────────────────────────────────────────
  Widget _buildPodium(List<dynamic> top3) {
    // Thứ tự hiển thị: 2 - 1 - 3
    final displayOrder = <int>[];
    if (top3.length >= 2) displayOrder.add(1);
    displayOrder.add(0);
    if (top3.length >= 3) displayOrder.add(2);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: displayOrder.map((idx) {
          if (idx >= top3.length) return const SizedBox(width: 110);
          return _buildPodiumSlot(top3[idx], idx + 1);
        }).toList(),
      ),
    );
  }

  Widget _buildPodiumSlot(dynamic entry, int rank) {
    // Màu & kích thước theo rank
    final medal = ['🥇', '🥈', '🥉'][rank - 1];
    final podiumH = [100.0, 70.0, 50.0][rank - 1];
    final podumColors = [
      [const Color(0xFFFFD700), const Color(0xFFFFF0AA)], // gold
      [const Color(0xFFB0BEC5), const Color(0xFFECEFF1)], // silver
      [const Color(0xFFBF8A60), const Color(0xFFEDD7BE)], // bronze
    ][rank - 1];

    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medal emoji
          Text(medal, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),

          // Avatar với viền
          _buildRobustAvatar(
            avatarUrl: entry.avatarUrl,
            displayName: entry.displayName,
            radius: rank == 1 ? 36.0 : 28.0,
          ),
          const SizedBox(height: 8),

          // Tên
          Text(
            entry.displayName.isNotEmpty ? entry.displayName : 'Ẩn danh',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // EP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              gradient: rank == 1
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    )
                  : null,
              color: rank != 1 ? podumColors[0].withOpacity(0.15) : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: podumColors[0].withOpacity(0.5)),
            ),
            child: Text(
              '${entry.weeklyEp} EP',
              style: TextStyle(
                color: rank == 1 ? Colors.white : AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bục podium
          Container(
            height: podiumH,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: podumColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: podumColors[0],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── List item #4+ ─────────────────────────────────────────────────────────
  Widget _buildListItem({required dynamic entry, required bool isMe}) {
    final lv = LevelHelper.levelFromEp(entry.weeklyEp ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primarySurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: isMe ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          _buildRobustAvatar(
            avatarUrl: entry.avatarUrl,
            displayName: entry.displayName,
            radius: 20,
          ),
          const SizedBox(width: 10),
          // Name + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName.isNotEmpty ? entry.displayName : 'Ẩn danh',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Lv.$lv · ${LevelHelper.badgeName(lv)}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Streak
          Row(
            children: [
              const Icon(Boxicons.bxs_flame, color: Colors.orange, size: 14),
              const SizedBox(width: 2),
              Text(
                '${entry.streakDays}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // EP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.weeklyEp} EP',
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPositionCard(dynamic profile) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Boxicons.bx_user, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Bạn chưa có điểm tuần này — hãy học ngay!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              '${profile.weeklyEp} EP',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Boxicons.bx_trophy,
              color: AppColors.primary,
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chưa có ai trên bảng xếp hạng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Học ngay để dẫn đầu tuần này! 🔥',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Avatar robust — fallback chữ cái khi ảnh lỗi hoặc đang chạy trên Web
  Widget _buildRobustAvatar({
    required String? avatarUrl,
    required String displayName,
    double radius = 20,
  }) {
    final raw = displayName.trimLeft();
    final initial = raw.isNotEmpty ? raw[0].toUpperCase() : 'U';
    final diameter = radius * 2;

    Widget fallback = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySurface,
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.65,
        ),
      ),
    );

    // Web: CORS block Google photos → luôn dùng fallback
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
}
