import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EssayPromptCard extends StatelessWidget {
  final String prompt;
  final double fontSize;

  const EssayPromptCard({super.key, required this.prompt, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(prompt, style: TextStyle(height: 1.5, fontSize: fontSize)),
    );
  }
}
