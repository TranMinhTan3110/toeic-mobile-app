import 'package:flutter/material.dart';
import '../../../core/theme/app_colors_home.dart';
import '../../../core/constants/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.sectionTitle),
      ],
    );
  }
}