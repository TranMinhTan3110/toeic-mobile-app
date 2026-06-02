import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/reading_part5_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_part5_practice_screen.dart';
import 'reading_part5_history_detail_screen.dart';
import '../../widgets/practice/part_history_sheet.dart';
import '../../../data/models/reading_part5_model.dart';


class ReadingPart5Screen extends StatefulWidget {
  const ReadingPart5Screen({super.key});

  @override
  State<ReadingPart5Screen> createState() => _ReadingPart5ScreenState();
}

class _ReadingPart5ScreenState extends State<ReadingPart5Screen> {
  int _questionCount = 10;
  int _maxQuestions = 0;
  bool _isLoadingCount = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMaxQuestions();
      context.read<ReadingPart5Provider>().fetchHistory();
    });
  }

  /// Bước 1: Lấy số câu bằng API count
  /// Bước 2: Đồng thời kick off preload data ở background
  /// Khi user bấm "Bắt đầu", data đã có sẵn trong cache.
  Future<void> _loadMaxQuestions() async {
    try {
      final provider = context.read<ReadingPart5Provider>();

      // Bước 1: Lấy count → hiển thị UI ngay (siêu nhanh)
      final count = await provider.getCountByPart();

      // Bước 2: Kick off preload không chặn UI
      provider.preloadInBackground();

      if (mounted) {
        setState(() {
          _maxQuestions = count;
          _questionCount = count > 0 ? (count < 10 ? count : 10) : 0;
          _isLoadingCount = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải số câu Part 5: $e');
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
    final readingProvider = context.watch<ReadingPart5Provider>();
    final totalDone = readingProvider.history.fold<int>(0, (sum, h) => sum + h.totalCount);
    final totalCorrect = readingProvider.history.fold<int>(0, (sum, h) => sum + h.correctCount);
    final completionRate = totalDone > 0 ? (totalCorrect / totalDone) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Part 5: Điền Vào Câu',
        actions: [
          // Nút lịch sử
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.appBarFg),
            onPressed: () => PartHistorySheet.show(
              context,
              partNumber: 5,
              partTitle: 'Reading Part 5',
              items: readingProvider.history.toHistoryItems(),
              onItemTap: (index) {
                if (index >= 0 && index < readingProvider.history.length) {
                  final historyItem = readingProvider.history[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadingPart5HistoryDetailScreen(
                        historyItem: historyItem,
                      ),
                    ),
                  );
                }
              },
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
              Container(
                margin: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.menu_book,
                          size: 38, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Row(label: 'Số câu đã làm', value: '$totalDone'),
                          const SizedBox(height: 4),
                          _Row(label: 'Trả lời đúng', value: '$totalCorrect'),
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
                                    value:
                                        completionRate.clamp(0.0, 1.0),
                                    backgroundColor: AppColors.primaryLighter,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
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
              ),

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
                    const Text(
                      'Trong phần này, bạn sẽ thấy một câu có chỗ trống. Hãy chọn đáp án đúng (A, B, C, hoặc D) để hoàn thành câu. Đọc kỹ và chọn lựa chọn phù hợp nhất.',
                      style: TextStyle(
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
                  builder: (_) =>
                      ReadingPart5PracticeScreen(questionCount: _questionCount),
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

// ── Bottom controls ───────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question count selector
            Row(
              children: [
                const Text(
                  'Số câu hỏi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<int>(
                      value: questionCount,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(8),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: [
                        if (maxQuestions >= 5)
                          const DropdownMenuItem(value: 5, child: Text('5')),
                        if (maxQuestions >= 10)
                          const DropdownMenuItem(value: 10, child: Text('10')),
                        if (maxQuestions >= 15)
                          const DropdownMenuItem(value: 15, child: Text('15')),
                        if (maxQuestions >= 20)
                          const DropdownMenuItem(value: 20, child: Text('20')),
                        if (maxQuestions >= 25)
                          const DropdownMenuItem(value: 25, child: Text('25')),
                        if (maxQuestions >= 30)
                          const DropdownMenuItem(
                              value: 30, child: Text('Tất cả')),
                      ],
                      onChanged: (v) {
                        if (v != null) onCountChanged(v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Start button
            ElevatedButton(
              onPressed: isLoading ? null : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                isLoading ? 'Đang tải...' : 'Bắt đầu nào',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wave painter ──────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.primary.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2,
        size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.4, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
