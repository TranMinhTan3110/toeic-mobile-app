import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/reading_part5_model.dart';
import '../../../providers/reading_part5_provider.dart';
import 'reading_part5_practice_screen.dart';
import 'reading_part5_history_overview_screen.dart';

class ReadingPart5HistoryDetailScreen extends StatefulWidget {
  final ReadingPart5HistoryModel historyItem;
  const ReadingPart5HistoryDetailScreen({super.key, required this.historyItem});

  @override
  State<ReadingPart5HistoryDetailScreen> createState() => _ReadingPart5HistoryDetailScreenState();
}

class _ReadingPart5HistoryDetailScreenState extends State<ReadingPart5HistoryDetailScreen> {
  bool _isLoadingQuestions = false;

  @override
  void initState() {
    super.initState();
    _preloadQuestionsIfNeeded();
  }

  void _preloadQuestionsIfNeeded() async {
    final provider = context.read<ReadingPart5Provider>();
    final hasCachedData = provider.questionsCacheData != null;

    if (!hasCachedData) {
      setState(() => _isLoadingQuestions = true);
      try {
        await provider.ensurePartLoaded();
      } catch (e) {
        debugPrint('Lỗi preload trong history detail: $e');
      } finally {
        if (mounted) setState(() => _isLoadingQuestions = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Lịch sử luyện tập'),
      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoadingQuestions
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Đang tải câu hỏi...', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.watch<ReadingPart5Provider>();
    final item = widget.historyItem;

    // Find session questions in cache
    final sessionQuestions = <ReadingPart5Question>[];
    final qCache = provider.questionsCacheData ?? provider.questions;
    for (var q in qCache ?? []) {
      if (item.selectedAnswers.containsKey(q.id)) sessionQuestions.add(q);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _buildBannerCard(item),
              const SizedBox(height: 16),
              _buildScoreDetailsCard(item),
              const SizedBox(height: 16),
              _buildWrongQuestionsSection(
                sessionQuestions.where((q) {
                  final sel = item.selectedAnswers[q.id];
                  return sel == null || sel != q.correctAnswer;
                }).toList(),
                item,
              ),
            ],
          ),
        ),

        _buildBottomControls(context, sessionQuestions),
      ],
    );
  }

  Widget _buildBannerCard(ReadingPart5HistoryModel item) {
    final scorePercent = item.percent;
    String comment = 'Hãy cố gắng hơn lần sau nhé!';
    if (scorePercent >= 80) {
      comment = 'Tuyệt vời! Bạn làm rất tốt, hãy duy trì phong độ nhé!';
    } else if (scorePercent >= 50) {
      comment = 'Khá lắm! Tập trung ôn tập kỹ để đạt kết quả tốt hơn nhé.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withRed(220)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.emoji_events_rounded, color: Colors.yellow, size: 48)),
          const SizedBox(height: 14),
          const Text('Bạn đã hoàn thành bài luyện tập', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Reading Part 5', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(comment, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildScoreDetailsCard(ReadingPart5HistoryModel item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))]),
      child: Row(
        children: [
          _AccuracyIndicator(percent: item.percent),
          const SizedBox(width: 24),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('KẾT QUẢ ĐẠT ĐƯỢC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textHint, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20), const SizedBox(width: 8), Text('Đúng: ${item.correctCount}/${item.totalCount} câu', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.stars_rounded, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text('Tỷ lệ chính xác: ${item.percent.toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary))]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildWrongQuestionsSection(List<ReadingPart5Question> wrongQuestions, ReadingPart5HistoryModel item) {
    if (wrongQuestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))]),
        child: const Column(children: [Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 48), SizedBox(height: 12), Text('Tuyệt vời! Không có câu hỏi sai', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)), SizedBox(height: 4), Text('Bạn đã trả lời đúng 100% các câu hỏi!', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.report_problem_rounded, color: Colors.orange, size: 20), const SizedBox(width: 8), Text('Danh sách câu hỏi sai (${wrongQuestions.length}):', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]), const SizedBox(height: 12), ...wrongQuestions.map((q) => _buildWrongQuestionCard(q, item))]);
  }

  Widget _buildWrongQuestionCard(ReadingPart5Question q, ReadingPart5HistoryModel item) {
    final selectedAns = item.selectedAnswers[q.id];
    final correctAns = q.correctAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q.prompt ?? 'Câu hỏi', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...List.generate(q.options.length, (idx) {
          final optionText = q.options[idx];
          final optionKey = String.fromCharCode(65 + idx);

          final isSelected = selectedAns == optionKey;
          final isCorrect = correctAns == optionKey;

          Color tileColor = AppColors.surface;
          Color borderColor = AppColors.divider;
          Widget? suffixIcon;

          if (isCorrect) {
            tileColor = AppColors.green.withOpacity(0.12);
            borderColor = AppColors.green;
            suffixIcon = const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20);
          } else if (isSelected) {
            tileColor = Colors.red.withOpacity(0.08);
            borderColor = Colors.red;
            suffixIcon = const Icon(Icons.cancel_rounded, color: Colors.red, size: 20);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: tileColor, border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [Container(width: 24, height: 24, decoration: BoxDecoration(color: isCorrect ? AppColors.green : (isSelected ? Colors.red : AppColors.divider), shape: BoxShape.circle), child: Center(child: Text(optionKey, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)))), const SizedBox(width: 12), Expanded(child: Text(optionText, style: TextStyle(fontSize: 13.5, fontWeight: (isCorrect || isSelected) ? FontWeight.bold : FontWeight.normal, color: AppColors.textPrimary))), if (suffixIcon != null) suffixIcon]),
          );
        }),
        const SizedBox(height: 12),
        const Divider(),
        _buildExplanationSection(q),
      ]),
    );
  }

  Widget _buildExplanationSection(ReadingPart5Question q) {
    final explanation = q.explanation ?? q.grammarExplanation ?? '';
    final explanationVi = q.explanationVi ?? q.translation ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (explanationVi.isNotEmpty) ...[
            Text('Lời dịch', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text(explanationVi, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.7, color: Colors.white)),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white24),
          ],
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Lời giải', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text(explanation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.7, color: Colors.white)),
            const SizedBox(height: 8),
            Container(height: 1, color: Colors.white24),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, List<ReadingPart5Question> sessionQuestions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))]),
      child: Row(children: [
        Expanded(child: ElevatedButton.icon(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingPart5HistoryOverviewScreen(historyItem: widget.historyItem, sessionQuestions: sessionQuestions)));
        }, icon: const Icon(Icons.assignment_rounded, color: Colors.white, size: 20), label: const Text('Chi tiết', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 3))), const SizedBox(width: 12), Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.of(context).pop(); }, icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 20), label: const Text('Làm lại', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 3)))
      ]),
    );
  }
}

class _AccuracyIndicator extends StatelessWidget {
  final double percent;
  const _AccuracyIndicator({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [SizedBox(width: 76, height: 76, child: CircularProgressIndicator(value: percent / 100.0, strokeWidth: 7, backgroundColor: AppColors.divider.withOpacity(0.5), valueColor: AlwaysStoppedAnimation<Color>(percent >= 70 ? AppColors.green : (percent >= 40 ? Colors.orange : Colors.red)))), Text('${percent.toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))]));
  }
}
