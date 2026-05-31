import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/writing_history_item.dart';
import 'essay_writing_test_screen.dart';
import 'picture_description_test_screen.dart';
import 'respond_request_test_screen.dart';
import 'writing_history_overview_screen.dart';

class WritingHistoryDetailScreen extends StatelessWidget {
  const WritingHistoryDetailScreen({super.key, required this.item});

  final WritingHistoryItem item;

  int get _questionCount {
    if (item.questionCount != null && item.questionCount! > 0) {
      return item.questionCount!;
    }
    if (item.questionIds.isNotEmpty) return item.questionIds.length;
    if (item.answers.isNotEmpty) return item.answers.length;
    return 1;
  }

  int get _partNumber {
    if (item.taskNumber != null && item.taskNumber! > 0) {
      return item.taskNumber!;
    }
    switch (item.taskType?.toLowerCase()) {
      case 'write_sentence':
        return 1;
      case 'respond_email':
        return 2;
      case 'opinion_essay':
        return 3;
      default:
        return 0;
    }
  }

  String get _partTitle {
    final label = item.taskTypeLabel == '-' ? 'Writing' : item.taskTypeLabel;
    final part = _partNumber;
    return part > 0 ? 'Part $part - $label' : label;
  }

  String get _feedbackSummary {
    final part = _partNumber > 0 ? ' Part $_partNumber' : '';
    return 'Hoàn thành phiên luyện tập$part.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kết quả luyện tập',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBannerCard(),
                const SizedBox(height: 16),
                _buildScoreDetailsCard(),
              ],
            ),
          ),
          _buildBottomControls(context),
        ],
      ),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
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
              color: Colors.white.withValues(alpha: 0.2),
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
            _partTitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hãy cố gắng hơn lần sau nhé!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailsCard() {
    if (!item.hasAiFeedback) {
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
            const _AccuracyIndicator(percent: 0),
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
                      Expanded(
                        child: Text(
                          'Đúng: 0/$_questionCount câu',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
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
                        'Tỷ lệ chính xác: 0%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
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

    final double score = item.aiScore?.toDouble() ?? 0.0;
    final scoreTen = score > 10 ? score / 10.0 : score;
    final toeicScore = (scoreTen * 20).round();

    final Map<String, double> criteria = {
      if (item.aiFeedback?.grammarScore != null)
        'Ngữ pháp': item.aiFeedback!.grammarScore!.toDouble(),
      if (item.aiFeedback?.vocabularyScore != null)
        'Từ vựng': item.aiFeedback!.vocabularyScore!.toDouble(),
      if (item.aiFeedback?.cohesionScore != null)
        'Bố cục & Liên kết': item.aiFeedback!.cohesionScore!.toDouble(),
    };

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BẢN ĐÁNH GIÁ CHUYÊN SÂU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textHint,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // Cột trái: Điểm trung bình & Ước lượng TOEIC
              Column(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: scoreTen / 10.0,
                            strokeWidth: 8,
                            backgroundColor: AppColors.divider.withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              scoreTen.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              '/10',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TOEIC: $toeicScore/200',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              
              // Cột phải: Thanh tiến trình các tiêu chí chấm điểm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: criteria.entries.map((entry) {
                    final key = entry.key;
                    final val = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${val.toStringAsFixed(1)}/10',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: val / 10.0,
                              minHeight: 6,
                              backgroundColor: AppColors.divider.withOpacity(0.4),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                val >= 7.5 ? AppColors.green : (val >= 5.0 ? Colors.orange : Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiFeedbackCard() {
    if (!item.hasAiFeedback) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primarySurface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryLighter.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
                SizedBox(width: 8),
                Text(
                  'Nhận xét từ AI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _feedbackSummary,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // AI General Feedback card
        Container(
          padding: const EdgeInsets.all(18),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primarySurface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryLighter.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Nhận xét từ AI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                (item.aiFeedback?.suggestedImprovement?.isNotEmpty == true)
                    ? 'Bài viết của bạn đã được giám khảo AI phân tích chi tiết.'
                    : _feedbackSummary,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Corrections Card (Phân tích lỗi sai)
        if (item.aiFeedback?.correctionsVi?.isNotEmpty == true) ...[
          Container(
            padding: const EdgeInsets.all(18),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.border_color_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Phân tích lỗi & Cách sửa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.aiFeedback!.correctionsVi!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Suggested Improvement Card (Bài viết cải tiến)
        if (item.aiFeedback?.suggestedImprovement?.isNotEmpty == true) ...[
          Container(
            padding: const EdgeInsets.all(18),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.green.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.offline_pin_rounded,
                      size: 16,
                      color: AppColors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bài viết đề xuất cải tiến',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.aiFeedback!.suggestedImprovement!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                    builder: (_) => WritingHistoryOverviewScreen(item: item),
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _retryPractice(context),
              icon: const Icon(
                Icons.replay_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Làm lại',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _retryPractice(BuildContext context) {
    final count = _questionCount;
    Widget screen;
    switch (_partNumber) {
      case 1:
        screen = PictureDescriptionTestScreen(
          questionLimit: count,
          retryHistoryId: item.id,
        );
        break;
      case 2:
        screen = RespondRequestTestScreen(
          questionLimit: count,
          retryHistoryId: item.id,
        );
        break;
      case 3:
        screen = EssayWritingTestScreen(
          questionLimit: count,
          retryHistoryId: item.id,
        );
        break;
      default:
        screen = PictureDescriptionTestScreen(
          questionLimit: count,
          retryHistoryId: item.id,
        );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _AccuracyIndicator extends StatelessWidget {
  const _AccuracyIndicator({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final progress = (percent / 100).clamp(0.0, 1.0);
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
              value: progress,
              strokeWidth: 7,
              backgroundColor: AppColors.divider.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 70 ? AppColors.green : Colors.orange,
              ),
            ),
          ),
          Text(
            '${percent.toInt()}%',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
