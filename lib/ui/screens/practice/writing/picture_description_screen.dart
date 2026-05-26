import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/writing_data.dart';
import '../../../../data/repositories/writing_repository.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/practice/part_history_sheet.dart';
import 'picture_description_test_screen.dart';

class PictureDescriptionScreen extends StatefulWidget {
  const PictureDescriptionScreen({super.key});

  @override
  State<PictureDescriptionScreen> createState() =>
      _PictureDescriptionScreenState();
}

class _PictureDescriptionScreenState extends State<PictureDescriptionScreen> {
  final WritingPartInfo part = WritingData.parts[0]; // Part 1
  int _questionCount = 1;
  late WritingRepository _repository;
  int _totalQuestions = 0;
  bool _loadingCount = true;

  @override
  void initState() {
    super.initState();
    _repository = WritingRepository();
    _loadTotalQuestions();
  }

  Future<void> _loadTotalQuestions() async {
    try {
      final questions = await _repository.getPracticeByTaskType('write_sentence');
      setState(() {
        _totalQuestions = questions.length;
        _questionCount = 1;
        _loadingCount = false;
      });
    } catch (e) {
      setState(() {
        _loadingCount = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: part.titleVi,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.appBarFg),
            onPressed: () => PartHistorySheet.show(
              context,
              partNumber: part.partNumber,
              partTitle: part.titleVi,
              items: WritingData.demoHistory(part.partNumber),
            ),
            tooltip: 'Lịch sử',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Wave background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 220,
            child: CustomPaint(painter: _WavePainter()),
          ),

          // Content
          ListView(
            padding: const EdgeInsets.only(bottom: 170),
            children: [
              _StatsHeader(part: part),
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
                      offset: Offset(0, 2),
                    ),
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
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomControls(
              questionCount: _questionCount,
              totalQuestions: _totalQuestions,
              loadingCount: _loadingCount,
              onCountChanged: (v) => setState(() => _questionCount = v),
              onStart: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PictureDescriptionTestScreen(
                    questionLimit: _questionCount,
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
  final WritingPartInfo part;

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
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
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
                    const Text(
                      'Hoàn thành',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.0,
                          backgroundColor: AppColors.primaryLighter,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
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
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.questionCount,
    required this.totalQuestions,
    required this.loadingCount,
    required this.onCountChanged,
    required this.onStart,
  });

  final int questionCount;
  final int totalQuestions;
  final bool loadingCount;
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
              const Text(
                'Số câu hỏi:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                child: loadingCount
                    ? const SizedBox(
                        width: 50,
                        height: 24,
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      )
                    : DropdownButton<int>(
                        value: questionCount,
                        isDense: true,
                        underline: const SizedBox(),
                        items: List.generate(
                          totalQuestions,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('${index + 1}'),
                          ),
                        ),
                        onChanged: (v) => onCountChanged(v!),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Bắt đầu nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
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
      canvas,
      size,
      AppColors.primaryLighter.withOpacity(0.5),
      0.35,
      0.2,
      0.6,
      0.35,
    );
    _drawWave(
      canvas,
      size,
      AppColors.primaryLighter.withOpacity(0.3),
      0.55,
      0.45,
      0.65,
      0.5,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Color color,
    double y0,
    double cy,
    double cx2,
    double y1,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * y0)
      ..quadraticBezierTo(size.width * 0.25, size.height * cy, size.width * 0.5,
          size.height * y0)
      ..quadraticBezierTo(size.width * 0.75, size.height * cx2, size.width,
          size.height * y1)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
