import 'package:flutter/material.dart';
import '../../../core/theme/app_colors_home.dart';
import '../../../core/constants/app_text_styles.dart';

class ExamCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const ExamCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                _buildIcon(),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.skillLabel,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }
}