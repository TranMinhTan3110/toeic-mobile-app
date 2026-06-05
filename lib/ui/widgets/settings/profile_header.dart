import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.email,
    this.avatarUrl,
    this.onLogout,
  });

  final bool isLoggedIn;
  final String? userName;
  final String? email;
  final String? avatarUrl;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildLoggedIn(context),
    );
  }

  Widget _buildLoggedIn(BuildContext context) {
    final resolvedName = userName?.trim().isNotEmpty == true
        ? userName!.trim()
        : 'Học viên TOEIC';
    final resolvedEmail = email?.trim();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                ? NetworkImage(avatarUrl!)
                : null,
            backgroundColor: AppColors.primaryLight,
            child: avatarUrl == null || avatarUrl!.isEmpty
                ? Text(
                    userName != null && userName!.isNotEmpty
                        ? userName!.trimLeft()[0].toUpperCase()
                        : 'B',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                resolvedName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                resolvedEmail?.isNotEmpty == true
                    ? resolvedEmail!
                    : 'Sẵn sàng cho buổi luyện hôm nay',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
