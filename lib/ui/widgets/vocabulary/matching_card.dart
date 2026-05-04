import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MatchingCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDying; 
  final bool isError;
  final AnimationController? shakeAnimation;
  final VoidCallback onTap;

  const MatchingCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isDying,
    required this.isError,
    this.shakeAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 500),
      padding: isDying ? const EdgeInsets.only(top: 80) : EdgeInsets.zero, 
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isDying ? 0.0 : 1.0, 
        child: AnimatedScale(
          duration: const Duration(milliseconds: 500),
          scale: isDying ? 0.8 : 1.0, 
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: isDying ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 90, 
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDying 
              ? AppColors.success.withOpacity(0.2) 
              : (isError ? AppColors.answerWrong : (isSelected ? AppColors.primarySurface : AppColors.surface)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDying 
                ? AppColors.success 
                : (isError ? AppColors.error : (isSelected ? AppColors.primary : AppColors.answerBorderDefault)),
            width: isSelected || isError || isDying ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected && !isError && !isDying) 
              BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
            if (!isSelected && !isError && !isDying)
              BoxShadow(color: AppColors.shadow.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            fontWeight: isSelected || isDying ? FontWeight.bold : FontWeight.w500,
            color: isDying 
                ? AppColors.success 
                : (isError ? AppColors.error : (isSelected ? AppColors.primary : AppColors.textPrimary)),
          ),
        ),
      ),
    );
  }
}
