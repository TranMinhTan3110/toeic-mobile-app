import 'package:flutter/material.dart';

/// Bảng màu trung tâm của ứng dụng TOEIC.
/// Sử dụng class này để lấy màu thay vì hard-code trực tiếp.
class AppColors {
  AppColors._(); // Không cho khởi tạo

  // ── Primary orange palette ────────────────────────────────────────────
  /// Màu cam chính – dùng cho nút, icon nhấn mạnh, tab active
  static const Color primary = Color(0xFFFF8C00);

  /// Phiên bản sáng hơn của màu cam – hover / pressed state
  static const Color primaryLight = Color(0xFFFFAD42);

  /// Phiên bản tối hơn của màu cam – border, focus ring
  static const Color primaryDark = Color(0xFFE65C00);

  /// Nền nhạt màu cam – chip, badge, card highlight
  static const Color primarySurface = Color(0xFFFFF3E0);

  // ── Neutral palette ───────────────────────────────────────────────────
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Colors.white;
  static const Color divider = Color(0xFFEEEEEE);

  // ── Text colors ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // ── Semantic colors ───────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color star = Color(0xFFFFB300);
}
