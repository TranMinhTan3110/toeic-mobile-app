import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const appBarTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
  );

  static const appBarSub = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );

  static const sectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const skillLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMid,
  );

  static const streakCount = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  static const streakLabel = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );

  static const bannerTitle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );

  static const bannerTag = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  static const navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static const badgeText = TextStyle(
    color: Colors.white,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}