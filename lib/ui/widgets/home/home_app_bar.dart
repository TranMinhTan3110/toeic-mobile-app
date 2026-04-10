import 'package:flutter/material.dart';
import '../../../core/theme/app_colors_home.dart';
import '../../../core/constants/app_text_styles.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trang Chủ', style: AppTextStyles.appBarTitle),
                    SizedBox(height: 2),
                    Text(
                      'TOEIC Master — Chinh phục điểm cao',
                      style: AppTextStyles.appBarSub,
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white24,
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}