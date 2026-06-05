import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

/// Widget AppBar dùng chung cho toàn app.
///
/// Cách dùng cơ bản:
/// ```dart
/// CustomAppBar(title: 'Ôn luyện kỹ năng')
/// ```
///
/// Với nút action phải (ví dụ: "Giải thích"):
/// ```dart
/// CustomAppBar(
///   title: 'Nghe',
///   actions: [
///     AppBarTextAction(label: 'Giải thích', onTap: () {}),
///   ],
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.centerTitle = false,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleStyle,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool centerTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final TextStyle? titleStyle;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.appBarBg;
    final fgColor = foregroundColor ?? AppColors.appBarFg;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      shadowColor: AppColors.shadow,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      titleSpacing: showBackButton ? 0 : 16,
      leading: showBackButton
          ? _BackButton(
              color: fgColor,
              onTap: onBack ?? () => Navigator.maybePop(context),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!showBackButton) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  'https://res.cloudinary.com/dlfc5qwhj/image/upload/q_auto/f_auto/v1780328432/Logo/logo-toeic_2.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: titleStyle ??
                TextStyle(
                  color: fgColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
      actions: [if (actions != null) ...actions!, const SizedBox(width: 8)],
      bottom: bottom,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      ),
    );
  }
}

// Back button

class _BackButton extends StatelessWidget {
  const _BackButton({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.appBarIconBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Boxicons.bx_chevron_left, color: color, size: 24),
      ),
    );
  }
}

// Reusable action widgets

// Nút text ở bên phải AppBar (ví dụ: "Giải thích")
class AppBarTextAction extends StatelessWidget {
  const AppBarTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.appBarIconBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? AppColors.appBarFg,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Nút icon ở bên phải AppBar
class AppBarIconAction extends StatelessWidget {
  const AppBarIconAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.appBarIconBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppColors.appBarFg, size: 20),
      ),
    );
  }
}
