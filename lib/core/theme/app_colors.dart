import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary / Brand
  static const Color primary         = Color(0xFFFF8C42);  // cam chủ đạo
  static const Color primaryLight    = Color(0xFFFFB07A);  // cam nhạt
  static const Color primaryLighter  = Color(0xFFFFD4B0);  // cam rất nhạt
  static const Color primaryDark     = Color(0xFFE06A1A);  // cam đậm

  // Background
  static const Color background      = Color(0xFFFFF8F3);  // nền tổng thể (trắng cam rất nhạt)
  static const Color surface         = Color(0xFFFFFFFF);  // nền card / panel
  static const Color surfaceVariant  = Color(0xFFFFF0E5);  // nền card phụ

  // AppBar
  static const Color appBarBg        = Color(0xFFFF8C00);
  static const Color appBarFg        = Color(0xFFFFFFFF);
  static const Color appBarIconBg    = Color(0xFFFFAD72);  // icon button bg trên AppBar

  // Text
  static const Color textPrimary     = Color(0xFF2D2D2D);
  static const Color textSecondary   = Color(0xFF757575);
  static const Color textHint        = Color(0xFFBDBDBD);
  static const Color textOnPrimary   = Color(0xFFFFFFFF);
  static const Color textLink        = Color(0xFFE06A1A);

  // Answer states
  static const Color answerDefault   = Color(0xFFFFFFFF);
  static const Color answerSelected  = Color(0xFFFFF0E5);
  static const Color answerCorrect   = Color(0xFFE8F5E9);
  static const Color answerWrong     = Color(0xFFFFEBEE);
  static const Color answerBorderDefault  = Color(0xFFE0E0E0);
  static const Color answerBorderSelected = Color(0xFFFF8C42);
  static const Color answerBorderCorrect  = Color(0xFF66BB6A);
  static const Color answerBorderWrong    = Color(0xFFEF5350);

  // Tab / Explanation
  static const Color tabActive       = Color(0xFFFF8C42);
  static const Color tabInactive     = Color(0xFFBDBDBD);
  static const Color tabIndicator    = Color(0xFFFF8C42);

  // Section badge
  static const Color badgeBg         = Color(0xFFFF8C42);
  static const Color badgeFg         = Color(0xFFFFFFFF);

  // Misc
  static const Color divider         = Color(0xFFEEEEEE);
  static const Color shadow          = Color(0x1AFF8C42);  // shadow nhẹ màu cam
  static const Color shimmer         = Color(0xFFFFF0E5);
  static const Color iconDefault     = Color(0xFF757575);
  static const Color iconOnPrimary   = Color(0xFFFFFFFF);
  static const Color success         = Color(0xFF66BB6A);
  static const Color error           = Color(0xFFEF5350);
  static const Color warning         = Color(0xFFFFA726);
  static const Color info            = Color(0xFF42A5F5);

  //home
  static const primaryPale   = Color(0xFFFFF0E5);
  static const border        = Color(0xFFFFE0C2);
  static const cardBg        = Colors.white;

  static const green         = Color(0xFF3B6D11);
  static const greenBg       = Color(0xFFEAF3DE);
  static const blue          = Color(0xFF185FA5);
  static const blueBg        = Color(0xFFE6F1FB);
  static const purple        = Color(0xFF534AB7);
  static const purpleBg      = Color(0xFFEEEDFE);

  static const textDark      = Color(0xFF2C2C2A);
  static const textMid       = Color(0xFF444441);
  static const textMuted     = Color(0xFF888780);

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFFB07A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF8F3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
