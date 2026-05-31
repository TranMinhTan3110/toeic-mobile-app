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

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month/$year';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMid,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(item.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
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
    final iconColor = item.color ?? AppColors.primary;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: item.icon != null
            ? Icon(
                item.icon,
                size: 18,
                color: iconColor,
              )
            : Text(
                'Aa',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
      ),
    );
  }
}