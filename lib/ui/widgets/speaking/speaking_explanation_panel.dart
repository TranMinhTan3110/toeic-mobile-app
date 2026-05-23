import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_question.dart';

class SpeakingExplanationPanel extends StatefulWidget {
  final bool isVisible;
  final SpeakingQuestion? question;
  final VoidCallback onClose;

  const SpeakingExplanationPanel({
    super.key,
    required this.isVisible,
    this.question,
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
    if (oldWidget.question?.taskNumber != widget.question?.taskNumber) {
      _initTabs();
    }
  }

  void _initTabs() {
    final taskNum = widget.question?.taskNumber ?? 1;
    if (taskNum == 1) {
      _tabs = ['Phụ đề', 'Lời dịch', 'Từ khoá'];
    } else if (taskNum == 2) {
      _tabs = ['Từ khoá', 'Dịch ngữ cảnh'];
    } else {
      _tabs = ['Dịch câu hỏi', 'Bài mẫu', 'Dịch bài mẫu'];
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
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              indicatorColor: Colors.white,
              dividerColor: Colors.transparent,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  String _joinList(List<String> list) {
    if (list.isEmpty) return 'Chưa có dữ liệu.';
    return list.asMap().entries.map((e) => 'Câu ${e.key + 1}: ${e.value}').join('\n\n');
  }

  Widget _buildTabContent() {
    if (widget.question == null) return const SizedBox(height: 200);
    
    final exp = widget.question!.explanation;
    List<Widget> children = [];
    
    for (var tab in _tabs) {
      if (tab == 'Phụ đề') {
        children.add(_ScrollableText(text: widget.question!.text));
      } else if (tab == 'Lời dịch') {
        children.add(_ScrollableText(text: exp?.translation ?? 'Chưa có lời dịch.'));
      } else if (tab == 'Từ khoá') {
        children.add(_KeywordList(keywords: exp?.keywords ?? []));
      } else if (tab == 'Dịch ngữ cảnh') {
        children.add(_ScrollableText(text: exp?.contextTranslation ?? 'Chưa có dịch ngữ cảnh.'));
      } else if (tab == 'Dịch câu hỏi') {
        children.add(_ScrollableText(text: _joinList(exp?.questionsTranslation ?? [])));
      } else if (tab == 'Bài mẫu') {
        final text = (exp != null && exp.sampleAnswers.isNotEmpty) 
            ? _joinList(exp.sampleAnswers) 
            : (widget.question!.sampleAnswer ?? 'Chưa có bài mẫu.');
        children.add(_ScrollableText(text: text));
      } else if (tab == 'Dịch bài mẫu') {
        children.add(_ScrollableText(text: _joinList(exp?.sampleAnswersTranslation ?? [])));
      }
    }

    return SizedBox(
      height: 250,
      child: TabBarView(controller: _tabController, children: children),
    );
  }
}

class _ScrollableText extends StatelessWidget {
  final String text;
  const _ScrollableText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6)),
    );
  }
}

class _KeywordList extends StatelessWidget {
  final List<KeywordItem> keywords;
  const _KeywordList({required this.keywords});

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) return const _ScrollableText(text: 'Chưa có từ khoá.');
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: keywords.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 20),
      itemBuilder: (_, i) {
        final kw = keywords[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(kw.word, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                if (kw.ipa != null) Text('  /${kw.ipa}/', style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 4),
            Text(kw.meaning, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        );
      },
    );
  }
}
