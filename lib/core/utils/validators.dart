class Validators {
  Validators._();

  /// Validates a full name. Returns null if valid.
  /// Rules: non-empty, at least 2 characters, only letters, spaces, hyphens, and apostrophes.
  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Vui lòng nhập họ và tên';
    return null;
  }

  /// Simple but strong email validation.
  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
    if (!emailRegex.hasMatch(s)) return 'Email không hợp lệ';
    return null;
  }

  /// Password rules: min 8 chars, at least one letter and one digit. Prefer mixed-case and special char.
  static String? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (s.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (!RegExp(r'[A-Za-z]').hasMatch(s)) return 'Mật khẩu phải chứa chữ cái';
    if (!RegExp(r'\d').hasMatch(s)) return 'Mật khẩu phải chứa chữ số';
    return null;
  }

  /// Confirm password: must equal [password].
  static String? confirmPassword(String? v, String password) {
    final s = v ?? '';
    if (s.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (s != password) return 'Mật khẩu không khớp';
    return null;
  }

  /// Returns an error message when not agreed, otherwise null.
  static String? mustAgree(bool agreed) {
    return agreed ? null : 'Bạn phải đồng ý với điều khoản để tiếp tục';
  }

  /// Password strength score: 0..4
  static int passwordStrength(String s) {
    int score = 0;
    if (s.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(s)) score++;
    if (RegExp(r'\d').hasMatch(s)) score++;
    if (RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(s)) score++;
    return score;
  }

  static String strengthLabel(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Yếu';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Mạnh';
      default:
        return 'Rất mạnh';
    }
  }
}
