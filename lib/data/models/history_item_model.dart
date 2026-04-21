class HistoryItem {
  final String title;
  final String type; // 'Luyện tập' | 'Thi'
  final double percent;
  final DateTime date;

  const HistoryItem({
    required this.title,
    required this.type,
    required this.percent,
    required this.date,
  });
}