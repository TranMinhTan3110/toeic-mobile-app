import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/reading_part7_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_part7_practice_screen.dart';
import 'reading_part7_history_detail_screen.dart';
import '../../widgets/practice/part_history_sheet.dart';
import '../../../data/models/reading_part7_model.dart';

class ReadingPart7Screen extends StatefulWidget {
  const ReadingPart7Screen({super.key});

  @override
  State<ReadingPart7Screen> createState() => _ReadingPart7ScreenState();
}

class _ReadingPart7ScreenState extends State<ReadingPart7Screen> {
  int _passageCount = 1;
  int _maxPassages = 0;
  bool _isLoadingCount = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMaxQuestions();
      context.read<ReadingPart7Provider>().fetchHistory();
    });
  }

  Future<void> _loadMaxQuestions() async {
    try {
      final provider = context.read<ReadingPart7Provider>();
      final count = await provider.getPassageCount();
      provider.preloadInBackground();
      if (mounted) {
        setState(() {
          _maxPassages = count;
          _passageCount = count > 0 ? 1 : 1;
          _isLoadingCount = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải số câu Part 7: $e');
      if (mounted) {
        setState(() {
          _maxPassages = 0;
          _passageCount = 1;
          _isLoadingCount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingPart7Provider>();
    final totalDone = provider.history.fold<int>(0, (sum, h) => sum + h.totalCount);
    final totalCorrect = provider.history.fold<int>(0, (sum, h) => sum + h.correctCount);
    final completionRate = totalDone > 0 ? (totalCorrect / totalDone) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Part 7: Đọc hiểu',
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.appBarFg),
            onPressed: () => PartHistorySheet.show(
              context,
              partNumber: 7,
              partTitle: 'Reading Part 7',
              items: provider.history.toHistoryItems(),
              onItemTap: (index) {
                if (index >= 0 && index < provider.history.length) {
                  final historyItem = provider.history[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadingPart7HistoryDetailScreen(
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
          Positioned(bottom: 0, left: 0, right: 0, height: 220, child: CustomPaint(painter: _WavePainter())),
          ListView(
            padding: const EdgeInsets.only(bottom: 170),
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Row(children: [
                  Container(width: 68, height: 68, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.menu_book, size: 38, color: AppColors.primary)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Row(label: 'Số câu đã làm', value: '$totalDone'),
                    const SizedBox(height: 4),
                    _Row(label: 'Trả lời đúng', value: '$totalCorrect'),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('Hoàn thành', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
                      const SizedBox(width: 10),
                      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: completionRate.clamp(0.0, 1.0), backgroundColor: AppColors.primaryLighter, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 6))),
                    ])
                  ]))
                ]),
              ),
              Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Cấu trúc', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15, decoration: TextDecoration.underline, decorationColor: AppColors.primary)),
                const SizedBox(height: 10),
                const Text('Trong phần này, bạn sẽ đọc các đoạn văn và trả lời các câu hỏi nhằm kiểm tra khả năng đọc hiểu.', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.65)),
              ])),
            ],
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _BottomControls(passageCount: _passageCount, maxPassages: _maxPassages, isLoading: _isLoadingCount, onCountChanged: (v) => setState(() => _passageCount = v), onStart: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingPart7PracticeScreen(passageCount: _passageCount))))),
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
    return Row(children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)), const SizedBox(width: 8), Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))]);
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.passageCount, required this.maxPassages, required this.isLoading, required this.onCountChanged, required this.onStart});

  final int passageCount;
  final int maxPassages;
  final bool isLoading;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && maxPassages <= 0) {
      return const SizedBox.shrink();
    }

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
            Row(
              children: [
                const Text(
                  'Số đoạn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      : maxPassages == 0
                          ? const Text(
                              'Không có đoạn văn',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14),
                            )
                          : DropdownButton<int>(
                              value: passageCount,
                              isDense: true,
                              underline: const SizedBox.shrink(),
                              borderRadius: BorderRadius.circular(8),
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              menuMaxHeight: 250,
                              items: List.generate(maxPassages, (index) => index + 1)
                                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) onCountChanged(v);
                              },
                            ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
