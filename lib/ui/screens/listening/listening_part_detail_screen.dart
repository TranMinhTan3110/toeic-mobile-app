import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/part_history_sheet.dart';
import '../../../data/models/listening_data.dart';
import '../../../data/repositories/listening_repository.dart';
import 'listening_practice_screen.dart';

/// Màn hình chuẩn bị trước khi làm bài – dùng chung cho cả 4 part.
/// Tên AppBar & mô tả thay đổi theo part.
class ListeningPartDetailScreen extends StatefulWidget {
  const ListeningPartDetailScreen({super.key, required this.part});
  final ListeningPartInfo part;

  @override
  State<ListeningPartDetailScreen> createState() =>
      _ListeningPartDetailScreenState();
}

class _ListeningPartDetailScreenState
    extends State<ListeningPartDetailScreen> {
  int _questionCount = 10;
  final ListeningRepository _repository = ListeningRepository();
  int _maxQuestions = 0;
  bool _isLoadingCount = true;

  @override
  void initState() {
    super.initState();
    _loadMaxQuestions();
  }

  Future<void> _loadMaxQuestions() async {
    try {
      int count = 0;
      if (widget.part.partNumber == 1 || widget.part.partNumber == 2) {
        final list = await _repository.getQuestionsByPart(widget.part.partNumber);
        count = list.length;
      } else {
        final list = await _repository.getGroupsByPart(widget.part.partNumber);
        count = list.length;
      }
      if (mounted) {
        setState(() {
          _maxQuestions = count;
          _questionCount = count > 0 ? (count < 10 ? count : 10) : 0;
          _isLoadingCount = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải số câu Part ${widget.part.partNumber}: $e');
      if (mounted) {
        setState(() {
          _maxQuestions = 0;
          _questionCount = 0;
          _isLoadingCount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: part.titleVi,
        actions: [
          // Nút lịch sử
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.appBarFg),
            onPressed: () => PartHistorySheet.show(
              context,
              partNumber: part.partNumber,
              partTitle: part.titleVi,
              items: ListeningData.demoHistory(part.partNumber),
            ),
            tooltip: 'Lịch sử',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Wave background
          Positioned(
            bottom: 0, left: 0, right: 0, height: 220,
            child: CustomPaint(painter: _WavePainter()),
          ),

          ListView(
            padding: const EdgeInsets.only(bottom: 170),
            children: [
              // ── Stats header ─────────────────────────────────
              _StatsHeader(part: part),

              // ── Instruction card ──────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Câu hỏi',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      part.description,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.65),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Bottom controls ───────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomControls(
              questionCount: _questionCount,
              maxQuestions: _maxQuestions,
              isLoading: _isLoadingCount,
              onCountChanged: (v) => setState(() => _questionCount = v),
              onStart: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListeningPracticeScreen(
                    part: part,
                    questionCount: _questionCount,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats header ─────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.part});
  final ListeningPartInfo part;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(part.icon, size: 38, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(label: 'Số câu đã làm', value: '0'),
                const SizedBox(height: 4),
                _Row(label: 'Trả lời đúng', value: '0'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Hoàn thành',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 13)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.0,
                          backgroundColor: AppColors.primaryLighter,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 13)),
        const SizedBox(width: 8),
        Text(value,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.questionCount,
    required this.maxQuestions,
    required this.isLoading,
    required this.onCountChanged,
    required this.onStart,
  });

  final int questionCount;
  final int maxQuestions;
  final bool isLoading;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Số câu hỏi:',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : maxQuestions == 0
                        ? const Text('Không có câu hỏi', style: TextStyle(color: AppColors.textSecondary, fontSize: 14))
                        : DropdownButton<int>(
                            value: questionCount,
                            isDense: true,
                            underline: const SizedBox(),
                            menuMaxHeight: 250, // Cố định chiều cao tối đa là 250px để danh sách không bị quá dài
                            items: List.generate(maxQuestions, (index) => index + 1)
                                .map((v) => DropdownMenuItem(
                                    value: v, child: Text('$v')))
                                .toList(),
                            onChanged: (v) => onCountChanged(v!),
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14),
                          ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isLoading || maxQuestions == 0) ? null : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              child: const Text('Bắt đầu nào',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave background ───────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
        canvas, size, AppColors.primaryLighter.withOpacity(0.5), 0.35, 0.2, 0.6, 0.35);
    _drawWave(
        canvas, size, AppColors.primaryLighter.withOpacity(0.3), 0.55, 0.45, 0.65, 0.5);
  }

  void _drawWave(Canvas canvas, Size size, Color color, double y0, double cy,
      double cx2, double y1) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * y0)
      ..quadraticBezierTo(size.width * 0.25, size.height * cy,
          size.width * 0.5, size.height * y0)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * cx2, size.width, size.height * y1)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
