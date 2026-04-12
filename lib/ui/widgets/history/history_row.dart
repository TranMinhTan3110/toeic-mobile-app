import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/history_item_model.dart';

class HistoryRow extends StatelessWidget {
  final HistoryItem item;

  const HistoryRow({super.key, required this.item});

  Color get _percentColor {
    if (item.percent >= 70) return AppColors.green;
    if (item.percent >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMid,
              ),
            ),
          ),
          Text(
            '${item.percent.toInt()}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _percentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Aa',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}