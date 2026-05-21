import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PracticeResultView extends StatefulWidget {
  final int score;
  final int total;
  final int mistakes;
  final int epAwarded;        // EP được cộng (0 = chưa load / không có)
  final bool epLoading;       // đang chờ API EP
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final String title;

  const PracticeResultView({
    super.key,
    required this.score,
    required this.total,
    this.mistakes = 0,
    this.epAwarded = 0,
    this.epLoading = false,
    required this.onRetry,
    required this.onBack,
    this.title = 'Hoàn thành buổi học!',
  });

  @override
  State<PracticeResultView> createState() => _PracticeResultViewState();
}

class _PracticeResultViewState extends State<PracticeResultView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    // Delay nhỏ để badge pop sau khi màn hình xuất hiện
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void didUpdateWidget(PracticeResultView old) {
    super.didUpdateWidget(old);
    // Khi epAwarded vừa nhận được (từ 0 → có giá trị), replay animation
    if (old.epLoading && !widget.epLoading && widget.epAwarded > 0) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isExcellent = widget.score == widget.total && widget.mistakes == 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExcellent ? Icons.emoji_events : Icons.check_circle,
              size: 100,
              color: isExcellent ? AppColors.star : AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.mistakes > 0) ...[
              Text(
                'Bạn đã ghép xong ${widget.total} từ.',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              Text(
                'Số lần chọn sai: ${widget.mistakes}',
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text(
                'Bạn đã trả lời đúng ${widget.score}/${widget.total} câu hỏi.',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],

            const SizedBox(height: 24),

            // ── EP Badge ─────────────────────────────────────────────
            _buildEpBadge(),

            const SizedBox(height: 32),

            // Nút Luyện lại
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: AppColors.textOnPrimary),
                    SizedBox(width: 8),
                    Text('Luyện lại', style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Nút Quay lại
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Quay lại danh sách',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpBadge() {
    // Đang chờ API
    if (widget.epLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            SizedBox(width: 10),
            Text('Đang tính EP...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // Không có EP (đã đạt cap hoặc lỗi)
    if (widget.epAwarded == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Text('Đã đạt giới hạn EP hôm nay',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      );
    }

    // Có EP — hiện badge với animation pop
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              '+${widget.epAwarded} EP',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
