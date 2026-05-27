import 'package:flutter/material.dart';

class HistoryItem {
  final String title;
  final DateTime date;
  final double percent;
  final String type; // 'practice' or 'exam'
  final IconData? icon;
  final Color? color;
  final String? score;

  HistoryItem({
    required this.title,
    required this.date,
    required this.percent,
    required this.type,
    this.icon,
    this.color,
    this.score,
  });
}
