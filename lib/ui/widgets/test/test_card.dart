import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Trạng thái của bài test.
enum TestStatus { notStarted, inProgress, completed }

extension TestStatusDisplay on TestStatus {
  String get label {
    switch (this) {
      case TestStatus.notStarted:
        return 'Chưa làm';
      case TestStatus.inProgress:
        return 'Đang làm';
      case TestStatus.completed:
        return 'Đã hoàn thành';
    }
  }

  Color get color {
    switch (this) {
      case TestStatus.notStarted:
        return AppColors.textHint;
      case TestStatus.inProgress:
        return AppColors.warning;
      case TestStatus.completed:
        return AppColors.success;
    }
  }

  IconData get icon {
    switch (this) {
      case TestStatus.notStarted:
        return Icons.radio_button_unchecked_rounded;
      case TestStatus.inProgress:
        return Icons.timelapse_rounded;
      case TestStatus.completed:
        return Icons.check_circle_rounded;
    }
  }
}

/// Card dùng trong danh sách đề thi thử.
///
/// Cách dùng:
/// ```dart
/// TestCard(
///   testName: 'TOEIC ETS 2024 – Test 01',
///   duration: '120 phút',
///   questionCount: 200,
///   status: TestStatus.completed,
///   score: 785,
///   onTap: () {},
/// )
/// ```
class TestCard extends StatelessWidget {
  const TestCard({
    super.key,
    required this.testName,
    this.duration,
    this.questionCount,
    this.status = TestStatus.notStarted,
    this.score,
    this.onTap,
    this.tag,
  });

  final String testName;
  final String? duration;
  final int? questionCount;
  final TestStatus status;

  /// Điểm (chỉ hiển thị khi status == completed).
  final int? score;

  final VoidCallback? onTap;

  /// Nhãn tuỳ chọn như "Hot", "Mới", v.v.
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: status == TestStatus.inProgress
              ? Border.all(color: AppColors.warning, width: 1.5)
              : Border.all(color: AppColors.divider, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: AppColors.iconOnPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                testName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (tag != null) ...[
                              const SizedBox(width: 6),
                              _TagBadge(label: tag!),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        _MetaRow(duration: duration, questionCount: questionCount),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 10),

              // ── Bottom row: status + score ────────────────────────
              Row(
                children: [
                  Icon(status.icon, size: 15, color: status.color),
                  const SizedBox(width: 5),
                  Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (status == TestStatus.completed && score != null)
                    _ScoreBadge(score: score!),
                  if (status != TestStatus.completed)
                    _StartButton(
                      label: status == TestStatus.inProgress ? 'Tiếp tục' : 'Bắt đầu',
                      onTap: onTap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sub-widgets

class _MetaRow extends StatelessWidget {
  const _MetaRow({this.duration, this.questionCount});
  final String? duration;
  final int? questionCount;

  @override
  Widget build(BuildContext context) {
    final items = <String>[];
    if (duration != null) items.add('$duration');
    if (questionCount != null) items.add('$questionCount câu');

    return Wrap(
      spacing: 12,
      children: items
          .map(
            (s) => Text(
              s,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          )
          .toList(),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;

  Color get _color {
    if (score >= 800) return AppColors.success;
    if (score >= 500) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        '$score điểm',
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
