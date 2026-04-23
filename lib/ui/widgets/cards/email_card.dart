import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EmailCard extends StatelessWidget {
  final String from;
  final String subject;
  final String content;

  const EmailCard({
    super.key,
    required this.from,
    required this.subject,
    required this.content,
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Subject: $subject'),
          const Divider(height: 20),

          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}
