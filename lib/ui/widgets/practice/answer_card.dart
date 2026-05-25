import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

/// Model cho 1 đáp án.
class AnswerOption {
  const AnswerOption({required this.key, required this.text});
  final String key; // 'A', 'B', 'C', 'D'
  final String text;
}

/// Trạng thái của mỗi đáp án.
enum AnswerState { normal, selected, correct, wrong }

/// Card bọc toàn bộ phần "Select the answer".
/// Bao gồm tiêu đề + danh sách các đáp án.
///
/// Cách dùng:
/// ```dart
/// AnswerCard(
///   options: const [
///     AnswerOption(key: 'A', text: 'She will attend the meeting.'),
///     AnswerOption(key: 'B', text: 'She has already left.'),
///     AnswerOption(key: 'C', text: 'She is running late.'),
///     AnswerOption(key: 'D', text: 'She does not know yet.'),
///   ],
///   selectedKey: _selected,
///   correctKey: null,          // null = chưa submit
///   onSelect: (key) => setState(() => _selected = key),
/// )
/// ```
class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.options,
    this.selectedKey,
    this.correctKey,
    this.onSelect,
    this.title = 'Chọn đáp án',
    this.fontSize = 14.0,
  });

  final List<AnswerOption> options;
  final String? selectedKey;

  /// Khi != null (sau khi submit), hiển thị kết quả đúng/sai.
  final String? correctKey;

  final ValueChanged<String>? onSelect;
  final String title;
  final double fontSize;

  AnswerState _stateOf(String key) {
    if (correctKey == null) {
      return key == selectedKey ? AnswerState.selected : AnswerState.normal;
    }
    if (key == correctKey) return AnswerState.correct;
    if (key == selectedKey && key != correctKey) return AnswerState.wrong;
    return AnswerState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 16),

          // Options
          ...options.map(
            (opt) => _AnswerTile(
              option: opt,
              state: _stateOf(opt.key),
              onTap: correctKey == null ? () => onSelect?.call(opt.key) : null,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Single answer tile

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.option, required this.state, this.onTap, required this.fontSize});

  final AnswerOption option;
  final AnswerState state;
  final VoidCallback? onTap;
  final double fontSize;

  Color get _bg {
    switch (state) {
      case AnswerState.selected:
        return AppColors.answerSelected;
      case AnswerState.correct:
        return AppColors.answerCorrect;
      case AnswerState.wrong:
        return AppColors.answerWrong;
      default:
        return AppColors.answerDefault;
    }
  }

  Color get _border {
    switch (state) {
      case AnswerState.selected:
        return AppColors.answerBorderSelected;
      case AnswerState.correct:
        return AppColors.answerBorderCorrect;
      case AnswerState.wrong:
        return AppColors.answerBorderWrong;
      default:
        return AppColors.answerBorderDefault;
    }
  }

  Color get _keyBg {
    switch (state) {
      case AnswerState.selected:
        return AppColors.primary;
      case AnswerState.correct:
        return AppColors.success;
      case AnswerState.wrong:
        return AppColors.error;
      default:
        return AppColors.surfaceVariant;
    }
  }

  Color get _keyFg {
    return state == AnswerState.normal
        ? AppColors.textSecondary
        : AppColors.textOnPrimary;
  }

  IconData? get _trailingIcon {
    switch (state) {
      case AnswerState.correct:
        return Icons.check_circle_rounded;
      case AnswerState.wrong:
        return Icons.cancel_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Row(
          children: [
            // Key badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _keyBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  option.key.length == 1 ? option.key : option.key[0].toUpperCase(),
                  style: TextStyle(
                    color: _keyFg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: fontSize,
                  height: 1.4,
                ),
              ),
            ),
            if (_trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                _trailingIcon,
                color: state == AnswerState.correct
                    ? AppColors.success
                    : AppColors.error,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
