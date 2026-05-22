import '../../ui/widgets/practice/answer_card.dart';

/// Gán nhãn A/B/C/D theo thứ tự; hỗ trợ dữ liệu có hoặc không có prefix "A.".
class PracticeOptionParser {
  PracticeOptionParser._();

  static const _labels = ['A', 'B', 'C', 'D'];

  /// Luôn gán A, B, C, D theo index (0→A, 1→B, …).
  static List<AnswerOption> toAnswerOptions(List<String> options) {
    return options.asMap().entries.map((entry) {
      final i = entry.key;
      final raw = entry.value;
      final key = i < _labels.length ? _labels[i] : '${i + 1}';
      return AnswerOption(key: key, text: displayText(raw));
    }).toList();
  }

  /// Nội dung hiển thị — bỏ prefix "A." / "A)" nếu có.
  static String displayText(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.length >= 2) {
      final letter = trimmed[0].toUpperCase();
      if ('ABCD'.contains(letter)) {
        final sep = trimmed[1];
        if (sep == '.' || sep == ')' || sep == ' ') {
          return trimmed.substring(2).trim();
        }
      }
    }

    return trimmed;
  }

  /// Chuẩn hóa đáp án đúng từ DB: "B", "B. ...", hoặc full text khớp 1 option.
  static String normalizeCorrectKey(String raw, {List<String>? options}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.length == 1 && 'ABCD'.contains(trimmed.toUpperCase())) {
      return trimmed.toUpperCase();
    }

    if (trimmed.length >= 2) {
      final letter = trimmed[0].toUpperCase();
      if ('ABCD'.contains(letter)) {
        final sep = trimmed[1];
        if (sep == '.' || sep == ')' || sep == ' ') {
          return letter;
        }
      }
    }

    final idx = int.tryParse(trimmed);
    if (idx != null && idx >= 1 && idx <= 4) {
      return _labels[idx - 1];
    }

    if (options != null) {
      final lower = trimmed.toLowerCase();
      for (var i = 0; i < options.length && i < _labels.length; i++) {
        final opt = options[i].trim().toLowerCase();
        final display = displayText(options[i]).toLowerCase();
        if (opt == lower || display == lower) {
          return _labels[i];
        }
      }
    }

    return trimmed.toUpperCase();
  }
}
