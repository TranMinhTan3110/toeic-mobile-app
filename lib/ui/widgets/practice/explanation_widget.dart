import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Các tab có trong phần giải thích.
enum ExplanationTab { explanation, transcript, translation }

extension ExplanationTabLabel on ExplanationTab {
  String get label {
    switch (this) {
      case ExplanationTab.explanation:
        return 'Giải thích';
      case ExplanationTab.transcript:
        return 'Transcript';
      case ExplanationTab.translation:
        return 'Dịch nghĩa';
    }
  }
}

/// Widget giải thích câu hỏi, gồm 3 tab: Giải thích / Transcript / Dịch nghĩa.
/// Có thể nhúng thẳng vào màn hình hoặc show qua bottom sheet.
///
/// Cách dùng inline:
/// ```dart
/// ExplanationWidget(
///   explanation: 'Đáp án đúng là A vì...',
///   transcript: 'Man: Hello, I was wondering...',
///   translation: 'Nam: Xin chào, tôi muốn hỏi...',
///   correctKey: 'A',
///   correctAnswerText: 'She will attend the meeting.',
/// )
/// ```
///
/// Cách mở bằng bottom sheet:
/// ```dart
/// ExplanationSheet.show(context, widget: ExplanationWidget(...));
/// ```
class ExplanationWidget extends StatefulWidget {
  const ExplanationWidget({
    super.key,
    required this.explanation,
    this.transcript,
    this.translation,
    this.correctKey,
    this.correctAnswerText,
    this.initialTab = ExplanationTab.explanation,
  });

  final String explanation;
  final String? transcript;
  final String? translation;
  final String? correctKey;
  final String? correctAnswerText;
  final ExplanationTab initialTab;

  @override
  State<ExplanationWidget> createState() => _ExplanationWidgetState();
}

class _ExplanationWidgetState extends State<ExplanationWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<ExplanationTab> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      ExplanationTab.explanation,
      if (widget.transcript != null) ExplanationTab.transcript,
      if (widget.translation != null) ExplanationTab.translation,
    ];
    final initialIndex = _tabs.indexOf(widget.initialTab);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Correct answer banner
          if (widget.correctKey != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.answerCorrect,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Đáp án đúng: ${widget.correctKey}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  if (widget.correctAnswerText != null) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '– ${widget.correctAnswerText}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Tab bar
          TabBar(
            controller: _tabController,
            isScrollable: _tabs.length > 2,
            labelColor: AppColors.tabActive,
            unselectedLabelColor: AppColors.tabInactive,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            indicatorColor: AppColors.tabIndicator,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Tab content
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((t) {
                final content = switch (t) {
                  ExplanationTab.explanation => widget.explanation,
                  ExplanationTab.transcript => widget.transcript ?? '',
                  ExplanationTab.translation => widget.translation ?? '',
                };
                return _TabContent(text: content);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.7,
        ),
      ),
    );
  }
}

// Bottom Sheet helper

class ExplanationSheet {
  ExplanationSheet._();

  static void show(BuildContext context, {required ExplanationWidget widget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: SingleChildScrollView(child: widget)),
            ],
          ),
        ),
      ),
    );
  }
}
