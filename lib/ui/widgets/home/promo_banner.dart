import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9A3C), Color(0xFFFF6B00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          _buildDecorativeCircle(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _buildTextContent(),
                const SizedBox(width: 12),
                _buildDiscountBadge(),
              ],
            ),
          ),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle() {
    return Positioned(
      right: -10,
      top: -20,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('ƯU ĐÃI ĐẶC BIỆT', style: AppTextStyles.bannerTag),
          ),
          const SizedBox(height: 8),
          const Text('Mở cơ hội đạt\n900+ TOEIC!', style: AppTextStyles.bannerTitle),
          const SizedBox(height: 4),
          const Text(
            'Nâng cấp ngay hôm nay',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            '50%',
            style: TextStyle(
              color: Color(0xFFE8650A),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Text(
            'Giảm giá',
            style: TextStyle(
              color: Color(0xFFE8650A),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Colors.white30,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 14),
      ),
    );
  }
}