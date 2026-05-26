import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../../providers/speaking_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/practice_stats_card.dart';
import 'speaking_doing_screen.dart';

class SpeakingPrepScreen extends StatefulWidget {
  final SpeakingPartInfo part;

  /// Số câu đã làm + tiến độ — truyền từ DB/provider
  final int totalDone;
  final int correct;
  final double progress;

  const SpeakingPrepScreen({
    super.key,
    required this.part,
    this.totalDone = 0,
    this.correct = 0,
    this.progress = 0,
  });

  @override
  State<SpeakingPrepScreen> createState() => _SpeakingPrepScreenState();
}

class _SpeakingPrepScreenState extends State<SpeakingPrepScreen> {
  late int _selectedCount;
  List<int> _questionOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedCount = widget.part.defaultQuestionCount;

    // Tải dữ liệu để biết tổng số câu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SpeakingProvider>()
          .fetchQuestionsByPart(widget.part.partNumber, practiceMode: true)
          .then((_) {
        if (mounted) {
          final total = context
              .read<SpeakingProvider>()
              .getQuestionsForPart(widget.part.partNumber, practiceMode: true)
              .length;
          setState(() {
            _generateOptions(total);
          });
        }
      });
    });
  }

  void _generateOptions(int total) {
    if (total <= 0) {
      _questionOptions = [widget.part.defaultQuestionCount];
      _selectedCount = widget.part.defaultQuestionCount;
      return;
    }
    
    List<int> options = [];
    if (total == 1) {
      options.add(1);
    } else {
      // Bước nhảy 2: 2, 4, 6... đến tổng số câu luyện tập
      for (int i = 2; i <= total; i += 2) {
        options.add(i);
      }
      if (!options.contains(total)) {
        options.add(total);
      }
    }

    _questionOptions = options;
    // Mặc định chọn số câu cao nhất
    _selectedCount = total;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeakingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.part.titleVi,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Wave background
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 220,
                  child: CustomPaint(painter: _WavePainter()),
                ),

                ListView(
                  padding: const EdgeInsets.only(bottom: 170),
                  children: [
                    const SizedBox(height: 16),
                    // ── Thẻ thống kê ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PracticeStatsCard(
                        icon: widget.part.icon,
                        totalDone: widget.totalDone,
                        correct: widget.correct,
                        progress: widget.progress,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Card mô tả câu hỏi ───────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildDescriptionCard(),
                    ),
                  ],
                ),

                // ── Bottom controls ───────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomControls(context),
                ),
              ],
            ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu hỏi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.part.descriptionEn,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.part.descriptionVi,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuestionDropdown() {
    if (_questionOptions.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCount,
          isDense: true,
          underline: const SizedBox(),
          menuMaxHeight: 250,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onChanged: (v) => setState(() => _selectedCount = v!),
          items: _questionOptions
              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
              .toList(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
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
              _buildQuestionDropdown(),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeakingDoingScreen(
                      part: widget.part,
                      questionCount: _selectedCount,
                      examMode: false,
                    ),
                  ),
                );
              },
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
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
