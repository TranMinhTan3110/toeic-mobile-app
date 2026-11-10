/// Hệ thống Level tăng dần — EP yêu cầu mỗi level tăng theo cấp số nhân
/// Lv1→2: 100 EP, Lv2→3: 250, Lv3→4: 500, Lv4→5: 900, Lv5→6: 1400...
class LevelHelper {
  // Ngưỡng EP tích lũy để đạt từng level (index = level - 1)
  // Level 1 bắt đầu từ 0 EP, Level 2 cần >= 100 EP, ...
  static const List<int> _thresholds = [
    0,     // Lv 1
    100,   // Lv 2
    350,   // Lv 3
    850,   // Lv 4
    1750,  // Lv 5
    3150,  // Lv 6
    5150,  // Lv 7
    7950,  // Lv 8
    11750, // Lv 9
    16750, // Lv 10 (max hiển thị)
  ];

  static const int maxLevel = 10;

  /// Tính level hiện tại từ tổng EP tích lũy
  static int levelFromEp(int totalEp) {
    int level = 1;
    for (int i = 1; i < _thresholds.length; i++) {
      if (totalEp >= _thresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }
    return level;
  }

  /// EP tích lũy tại đầu level [lv]
  static int epAtLevel(int lv) {
    final idx = (lv - 1).clamp(0, _thresholds.length - 1);
    return _thresholds[idx];
  }

  /// EP cần để lên level tiếp theo (từ đầu level hiện tại đến đầu level sau)
  static int epRequiredForLevel(int lv) {
    if (lv >= maxLevel) return 0; // đã max
    return _thresholds[lv] - _thresholds[lv - 1];
  }

  /// EP đã tích lũy trong level hiện tại
  static int epProgressInLevel(int totalEp) {
    final lv = levelFromEp(totalEp);
    return totalEp - epAtLevel(lv);
  }

  /// Tỷ lệ tiến độ trong level hiện tại (0.0 - 1.0)
  static double progressRatio(int totalEp) {
    final lv = levelFromEp(totalEp);
    if (lv >= maxLevel) return 1.0;
    final required = epRequiredForLevel(lv);
    if (required == 0) return 1.0;
    return (epProgressInLevel(totalEp) / required).clamp(0.0, 1.0);
  }

  /// EP cần thêm để lên level tiếp
  static int epToNextLevel(int totalEp) {
    final lv = levelFromEp(totalEp);
    if (lv >= maxLevel) return 0;
    return epAtLevel(lv + 1) - totalEp;
  }

  /// Tên huy hiệu theo level
  static String badgeName(int lv) {
    switch (lv) {
      case 1:  return 'Tân Binh 🐣';
      case 2:  return 'Người Học Chăm 📚';
      case 3:  return 'Chiến Binh Từ Vựng ⚔️';
      case 4:  return 'Sát Thủ TOEIC 🎯';
      case 5:  return 'Cao Thủ 🔥';
      case 6:  return 'Huyền Thoại 🌟';
      case 7:  return 'Vô Song 💎';
      case 8:  return 'Bất Khả Chiến Bại 🏆';
      case 9:  return 'Siêu Nhân TOEIC 🦸';
      case 10: return 'TOEIC Master 👑';
      default: return 'Huyền Thoại 🌟';
    }
  }

  /// Màu gradient theo level
  static List<int> levelColors(int lv) {
    // Trả về [colorStart, colorEnd] dưới dạng hex int
    switch (lv) {
      case 1:  return [0xFF9E9E9E, 0xFFBDBDBD]; // Gray
      case 2:  return [0xFF66BB6A, 0xFF43A047]; // Green
      case 3:  return [0xFF29B6F6, 0xFF0288D1]; // Blue
      case 4:  return [0xFF7E57C2, 0xFF512DA8]; // Purple
      case 5:  return [0xFFFF7043, 0xFFE64A19]; // Orange
      case 6:  return [0xFFEF5350, 0xFFC62828]; // Red
      case 7:  return [0xFFEC407A, 0xFFAD1457]; // Pink
      case 8:  return [0xFFFFCA28, 0xFFF9A825]; // Gold
      case 9:  return [0xFF26C6DA, 0xFF00838F]; // Teal
      case 10: return [0xFFFF6F00, 0xFFFF8F00]; // Amber Crown
      default: return [0xFFFF7043, 0xFFE64A19];
    }
  }
}
