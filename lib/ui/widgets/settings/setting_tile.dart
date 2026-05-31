import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailingWidget,
    this.trailingText,
    this.trailingTextColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
  final String? trailingText;
  final Color? trailingTextColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: TextStyle(
                    color: trailingTextColor ?? AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ?trailingWidget,
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.tabInactive),
            ],
          ),
        ),
      ),
    );
  }
}
