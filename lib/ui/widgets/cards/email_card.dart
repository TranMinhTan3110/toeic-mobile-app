import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EmailCard extends StatelessWidget {
  final String from;
  final String subject;
  final String content;
  final double fontSize;

  const EmailCard({
    super.key,
    required this.from,
    required this.subject,
    required this.content,
    this.fontSize = 14,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'From: $from',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
          const SizedBox(height: 4),
          Text('Subject: $subject', style: TextStyle(fontSize: fontSize)),
          const Divider(height: 20),
          Text(content, style: TextStyle(height: 1.5, fontSize: fontSize)),
        ],
      ),
    );
  }
}
