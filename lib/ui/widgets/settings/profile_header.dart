import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.avatarUrl,
    this.onLogout,
  });

  final bool isLoggedIn;
  final String? userName;
  final String? avatarUrl;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: isLoggedIn ? _buildLoggedIn(context) : _buildGuest(context),
    );
  }

  Widget _buildGuest(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryLighter,
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Text('Đăng nhập',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
              ),
              const SizedBox(width: 8),
              Text('|', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Text('Đăng ký',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedIn(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          backgroundColor: AppColors.primaryLighter,
          child: avatarUrl == null
              ? Text(
                  userName != null && userName!.isNotEmpty
                      ? userName![0].toUpperCase()
                      : 'B',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName ?? 'Người dùng',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onLogout,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('Đăng xuất',
                style: TextStyle(
                  color: AppColors.textLink,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ),
      ],
    );
  }
}
