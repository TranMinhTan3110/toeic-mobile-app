import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class InstructionCard extends StatelessWidget {
  const InstructionCard({
    super.key,
    required this.title,
    required this.english,
    required this.vietnamese,
  });

  final String title;
  final List<String> english;
  final List<String> vietnamese;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          ...english.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('- $e'),
            ),
          ),

          const Divider(height: 24),

          ...vietnamese.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '- $e',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
