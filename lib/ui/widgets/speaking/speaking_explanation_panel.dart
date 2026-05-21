import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

/// Panel trượt lên từ dưới màn hình, hiển thị 3 tab:
/// Phụ đề · Lời dịch · Từ khoá.
///
/// Cách dùng: nhúng thẳng vào Stack bên dưới nội dung chính,
/// hiển thị/ẩn bằng [isVisible].
///
/// ```dart
/// Stack(children: [
///   _buildBody(),
///   SpeakingExplanationPanel(
///     isVisible: _showPanel,
///     transcript: '...',
///     translation: '...',
///     keywords: [KeywordItem(word: 'personnel', meaning: 'nhân sự')],
///     onClose: () => setState(() => _showPanel = false),
///   ),
/// ])
/// ```
class SpeakingExplanationPanel extends StatefulWidget {
  final bool isVisible;
  final String? transcript;
  final String? translation;
  final List<KeywordItem> keywords;
  final VoidCallback onClose;

  const SpeakingExplanationPanel({
    super.key,
    required this.isVisible,
    this.transcript,
    this.translation,
    this.keywords = const [],
    required this.onClose,
  });

  @override
  State<SpeakingExplanationPanel> createState() =>
      _SpeakingExplanationPanelState();
}

class _SpeakingExplanationPanelState extends State<SpeakingExplanationPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: widget.isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: widget.isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: _buildPanel(context),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabBar(),
          const Divider(height: 1, color: Colors.white24),
          _buildTabContent(),
        ],
      ),
    );
  }

  // ── Tab bar ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white, width: 2.5),
                insets: EdgeInsets.symmetric(horizontal: 16),
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Phụ đề'),
                Tab(text: 'Lời dịch'),
                Tab(text: 'Từ khoá'),
              ],
            ),
          ),
          // nút đóng
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ── Nội dung các tab ─────────────────────────────────────────────────────
  Widget _buildTabContent() {
    return SizedBox(
      height: 180,
      child: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Phụ đề (transcript)
          _ScrollableText(
            text: widget.transcript ??
                'Chưa có phụ đề cho câu hỏi này.',
          ),

          // Tab 2: Lời dịch (translation)
          _ScrollableText(
            text: widget.translation ??
                'Chưa có lời dịch cho câu hỏi này.',
          ),

          // Tab 3: Từ khoá
          widget.keywords.isEmpty
              ? _ScrollableText(text: 'Chưa có từ khoá.')
              : _KeywordList(keywords: widget.keywords),
        ],
      ),
    );
  }
}

// ── Scrollable text tab ───────────────────────────────────────────────────────
class _ScrollableText extends StatelessWidget {
  final String text;
  const _ScrollableText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.75,
        ),
      ),
    );
  }
}

// ── Keyword list tab ──────────────────────────────────────────────────────────
class _KeywordList extends StatelessWidget {
  final List<KeywordItem> keywords;
  const _KeywordList({required this.keywords});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      itemCount: keywords.length,
      separatorBuilder: (_, __) =>
      const Divider(color: Colors.white24, height: 14),
      itemBuilder: (_, i) {
        final kw = keywords[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // từ tiếng Anh
            SizedBox(
              width: 130,
              child: Text(
                kw.word,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // nghĩa tiếng Việt
            Expanded(
              child: Text(
                kw.meaning,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Data model từ khoá ────────────────────────────────────────────────────────
class KeywordItem {
  final String word;
  final String meaning;
  const KeywordItem({required this.word, required this.meaning});
}