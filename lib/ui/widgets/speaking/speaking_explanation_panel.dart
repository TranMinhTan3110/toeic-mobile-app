import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

class SpeakingExplanationPanel extends StatefulWidget {
  final bool isVisible;
  final int partNumber;
  final String? transcript;
  final String? translation;
  final List<KeywordItem> keywords;
  final String? sampleAnswer;
  final String? sampleTranslation;
  final VoidCallback onClose;

  const SpeakingExplanationPanel({
    super.key,
    required this.isVisible,
    required this.partNumber,
    this.transcript,
    this.translation,
    this.keywords = const [],
    this.sampleAnswer,
    this.sampleTranslation,
    required this.onClose,
  });

  @override
  State<SpeakingExplanationPanel> createState() =>
      _SpeakingExplanationPanelState();
}

class _SpeakingExplanationPanelState extends State<SpeakingExplanationPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> _tabs = [];

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  @override
  void didUpdateWidget(SpeakingExplanationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partNumber != widget.partNumber) {
      _initTabs();
    }
  }

  void _initTabs() {
    if (widget.partNumber == 1) {
      _tabs = ['Phụ đề', 'Lời dịch', 'Từ khoá'];
    } else if (widget.partNumber == 2) {
      _tabs = ['Từ khoá'];
    } else {
      // Parts 3, 4, 5
      _tabs = ['Lời dịch', 'Bài mẫu', 'Dịch bài mẫu'];
    }
    _tabController = TabController(length: _tabs.length, vsync: this);
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
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
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

  Widget _buildTabContent() {
    List<Widget> children = [];
    
    for (var tab in _tabs) {
      if (tab == 'Phụ đề') {
        children.add(_ScrollableText(text: widget.transcript ?? 'Chưa có phụ đề.'));
      } else if (tab == 'Lời dịch') {
        children.add(_ScrollableText(text: widget.translation ?? 'Chưa có lời dịch.'));
      } else if (tab == 'Từ khoá') {
        children.add(widget.keywords.isEmpty
            ? const _ScrollableText(text: 'Chưa có từ khoá.')
            : _KeywordList(keywords: widget.keywords));
      } else if (tab == 'Bài mẫu') {
        children.add(_ScrollableText(text: widget.sampleAnswer ?? 'Chưa có bài mẫu.'));
      } else if (tab == 'Dịch bài mẫu') {
        children.add(_ScrollableText(text: widget.sampleTranslation ?? 'Chưa có dịch bài mẫu.'));
      }
    }

    return SizedBox(
      height: 200,
      child: TabBarView(
        controller: _tabController,
        children: children,
      ),
    );
  }
}

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

class KeywordItem {
  final String word;
  final String meaning;
  const KeywordItem({required this.word, required this.meaning});
}
