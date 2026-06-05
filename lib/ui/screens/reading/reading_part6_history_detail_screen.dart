import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/reading_part6_model.dart';
import '../../../providers/reading_part6_provider.dart';
import 'reading_part6_practice_screen.dart';
import 'reading_part6_history_overview_screen.dart';

class ReadingPart6HistoryDetailScreen extends StatefulWidget {
  final ReadingPart6HistoryModel historyItem;
  const ReadingPart6HistoryDetailScreen({super.key, required this.historyItem});

  @override
  State<ReadingPart6HistoryDetailScreen> createState() =>
      _ReadingPart6HistoryDetailScreenState();
}

class _ReadingPart6HistoryDetailScreenState
    extends State<ReadingPart6HistoryDetailScreen> {
  bool _isLoadingQuestions = false;

  @override
  void initState() {
    super.initState();
    _preloadQuestionsIfNeeded();
  }

  void _preloadQuestionsIfNeeded() async {
    final provider = context.read<ReadingPart6Provider>();
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
                        Text(
                          'Đang tải câu hỏi...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
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
    final provider = context.watch<ReadingPart6Provider>();
    final item = widget.historyItem;

    final sessionQuestions = <ReadingPart6Question>[];
    final qCache = provider.questionsCacheData ?? provider.questions;
    for (var q in qCache ?? []) {
      if (item.selectedAnswers.containsKey(q.id)) sessionQuestions.add(q);
    }

    // Chỉ lấy đúng số lượng câu theo totalCount để tránh hiển thị câu từ phiên khác
    if (sessionQuestions.length > item.totalCount) {
      sessionQuestions.removeRange(item.totalCount, sessionQuestions.length);
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
            ],
          ),
        ),

        _buildBottomControls(context, sessionQuestions),
      ],
    );
  }

  Widget _buildBannerCard(ReadingPart6HistoryModel item) {
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
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withRed(220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.yellow,
              size: 48,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Bạn đã hoàn thành bài luyện tập',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reading Part 6',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailsCard(ReadingPart6HistoryModel item) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          _AccuracyIndicator(percent: item.percent),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KẾT QUẢ ĐẠT ĐƯỢC',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHint,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đúng: ${item.correctCount}/${item.totalCount} câu',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tỷ lệ chính xác: ${item.percent.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.local_library_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Điểm kinh nghiệm: +${item.correctCount > 0 ? (item.correctCount * 3) + 5 : 0} EP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
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

  

  Widget _buildBottomControls(
    BuildContext context,
    List<ReadingPart6Question> sessionQuestions,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReadingPart6HistoryOverviewScreen(
                      historyItem: widget.historyItem,
                      sessionQuestions: sessionQuestions,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.assignment_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Chi tiết',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.replay_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Làm lại',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyIndicator extends StatelessWidget {
  final double percent;
  const _AccuracyIndicator({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: CircularProgressIndicator(
              value: percent / 100.0,
              strokeWidth: 7,
              backgroundColor: AppColors.divider.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 70
                    ? AppColors.green
                    : (percent >= 40 ? Colors.orange : Colors.red),
              ),
            ),
          ),
          Text(
            '${percent.toInt()}%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
