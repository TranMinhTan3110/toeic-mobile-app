import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const _items = [
    _NavItemData(icon: Icons.home_rounded,     label: 'Trang Chủ'),
    // _NavItemData(icon: Icons.history,           label: 'Lịch sử'),
    _NavItemData(icon: Icons.grid_view_rounded, label: 'Đề thi'),
    _NavItemData(icon: Icons.person_outline,    label: 'Hồ sơ'),
    _NavItemData(icon: Icons.settings_outlined, label: 'Cài đặt'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
                  (i) => _NavItemWidget(
                data: _items[i],
                isActive: i == currentIndex,
                onTap: () => onTap?.call(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

class _NavItemWidget extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItemWidget({
    required this.data,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: AppTextStyles.navLabel.copyWith(color: color),
          ),
          if (isActive) ...[
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}