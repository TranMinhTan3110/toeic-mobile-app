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
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      userProvider.fetchProfile(forceRefresh: true),
                      userProvider.fetchLeaderboard(forceRefresh: true),
                    ]);
                  },
                  color: AppColors.primary,
                  child: isLoading && leaderboard.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : leaderboard.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  child: _buildEmpty(),
                                ),
                              ],
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
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
      padding: const EdgeInsets.fromLTRB(8, 36, 8, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryLighter.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
    // Chiều cao bục và dải màu bục bọc kim loại
    final podiumH = [110.0, 75.0, 55.0][rank - 1];
    
    // Khung màu viền và đổ bóng cho avatar theo thứ hạng
    final frameColor = [
      const Color(0xFFFFA000), // Gold
      const Color(0xFF78909C), // Silver
      const Color(0xFF8D6E63), // Bronze
    ][rank - 1];

    final podiumGradientColors = [
      [const Color(0xFFFFD54F), const Color(0xFFFFB300), const Color(0xFFFF8F00)], // Gold pedestal
      [const Color(0xFFECEFF1), const Color(0xFFB0BEC5), const Color(0xFF78909C)], // Silver pedestal
      [const Color(0xFFEDD7BE), const Color(0xFFBF8A60), const Color(0xFF8D6E63)], // Bronze pedestal
    ][rank - 1];

    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Khu vực Avatar có Crown và Medal Badge đè lên nhau
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Avatar tròn có viền phát sáng nhẹ
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      frameColor.withOpacity(0.9),
                      frameColor.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: frameColor.withOpacity(0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildRobustAvatar(
                  avatarUrl: entry.avatarUrl,
                  displayName: entry.displayName,
                  radius: rank == 1 ? 34.0 : 26.0,
                  rank: rank,
                ),
              ),
              // Vương miện hoàng gia nổi bật ở vị trí số 1
              if (rank == 1)
                Positioned(
                  top: -24,
                  child: Icon(
                    Boxicons.bxs_crown,
                    color: const Color(0xFFFFD54F),
                    size: 26,
                    shadows: [
                      Shadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              // Huy hiệu số 1-2-3 tròn nhỏ đè dưới avatar cực đẹp
              Positioned(
                bottom: -10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          frameColor,
                          frameColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18), // Khoảng đệm cho huy hiệu lấn xuống

          // Tên người dùng
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
          const SizedBox(height: 6),

          // EP Badge sinh động có kèm Icon năng lượng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              gradient: rank == 1 ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]) : null,
              color: rank != 1 ? frameColor.withOpacity(0.12) : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: frameColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rank == 1) ...[
                  const Icon(Boxicons.bxs_zap, color: Colors.white, size: 10),
                  const SizedBox(width: 3),
                ],
                Text(
                  '${entry.weeklyEp} EP',
                  style: TextStyle(
                      color: rank == 1 ? Colors.white : AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bục Podium Metallic bo góc mềm mại cao cấp
          Container(
            height: podiumH,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: podiumGradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(
                color: Colors.white.withOpacity(0.55),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: frameColor.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    shadows: [
                      Shadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
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
    int? rank,
  }) {
    final raw = displayName.trimLeft();
    final initial = raw.isNotEmpty ? raw[0].toUpperCase() : 'U';
    final diameter = radius * 2;

    final initialColor = (rank != null && rank <= 3)
        ? [
            const Color(0xFFE65100), // Gold text contrast
            const Color(0xFF37474F), // Silver text contrast
            const Color(0xFF4E342E), // Bronze text contrast
          ][rank - 1]
        : AppColors.primary;

    final initialGradient = (rank != null && rank <= 3)
        ? [
            const LinearGradient(
              colors: [Color(0xFFFFF9C4), Color(0xFFFFE082)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ), // Gold theme
            const LinearGradient(
              colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ), // Silver theme
            const LinearGradient(
              colors: [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ), // Bronze theme
          ][rank - 1]
        : const LinearGradient(
            colors: [Color(0xFFFFECE0), Color(0xFFFFE0D0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ); // Elegant peach brand gradient

    Widget fallback = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: initialGradient,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: initialColor,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.75,
            letterSpacing: 0.5,
          ),
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
