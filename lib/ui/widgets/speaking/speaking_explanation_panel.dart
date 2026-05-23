import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_question.dart';

class SpeakingExplanationPanel extends StatefulWidget {
  final bool isVisible;
  final SpeakingQuestion? question;
  final int partNumber;
  final VoidCallback onClose;

  const SpeakingExplanationPanel({
    super.key,
    required this.isVisible,
    this.question,
    required this.partNumber,
    required this.onClose,
  });

  @override
  State<SpeakingExplanationPanel> createState() =>
      _SpeakingExplanationPanelState();
}

class _SpeakingExplanationPanelState extends State<SpeakingExplanationPanel>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> _tabs = [];

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  @override
  void didUpdateWidget(SpeakingExplanationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật lại tabs nếu câu hỏi thay đổi hoặc dữ liệu (như keywords) được load
    if (oldWidget.question?.id != widget.question?.id || 
        oldWidget.partNumber != widget.partNumber ||
        oldWidget.question?.explanation?.keywords.length != widget.question?.explanation?.keywords.length) {
      _initTabs();
    }
  }

  void _initTabs() {
    final taskNum = widget.partNumber;
    final exp = widget.question?.explanation;
    final List<String> newTabs = [];

    if (taskNum == 1) {
      newTabs.addAll(['Phụ đề', 'Lời dịch']);
    } else if (taskNum == 2) {
      // Part 2 thường chỉ có từ khóa
    } else {
      // Parts 3, 4, 5
      newTabs.add('Dịch câu hỏi');
    }

    // Chỉ thêm tab Từ khoá nếu có dữ liệu
    if (exp != null && exp.keywords.isNotEmpty) {
      newTabs.add('Từ khoá');
    }

    if (taskNum >= 3) {
      newTabs.addAll(['Bài mẫu', 'Dịch bài mẫu']);
    }

    // Fallback nếu không có gì để hiện
    if (newTabs.isEmpty) newTabs.add('Thông tin');

    setState(() {
      _tabs = newTabs;
      _tabController?.dispose();
      _tabController = TabController(length: _tabs.length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
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
          if (_tabs.isNotEmpty) _buildTabBar(),
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
              isScrollable: _tabs.length > 3,
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

  List<String> _sampleAnswers(SpeakingExplanation? exp) {
    if (exp != null && exp.sampleAnswers.isNotEmpty) return exp.sampleAnswers;
    final top = widget.question?.sampleAnswer?.trim();
    if (top != null && top.isNotEmpty) return [top];
    return const [];
  }

  List<String> _sampleAnswersTranslation(SpeakingExplanation? exp) =>
      exp?.sampleAnswersTranslation ?? const [];

  String _joinList(List<String> list, bool isSingle) {
    if (list.isEmpty) return 'Chưa có dữ liệu.';
    if (isSingle || list.length == 1) return list.first;
    return list.asMap().entries.map((e) => 'Câu ${e.key + 1}: ${e.value}').join('\n\n');
  }

  Widget _buildTabContent() {
    if (widget.question == null || _tabController == null) return const SizedBox(height: 200);
    
    final exp = widget.question!.explanation;
    final isPart5 = widget.partNumber == 5;
    List<Widget> children = [];
    
    for (var tab in _tabs) {
      switch (tab) {
        case 'Phụ đề':
          children.add(_ScrollableText(text: widget.question!.text));
          break;
        case 'Lời dịch':
          children.add(_ScrollableText(text: exp?.translation ?? 'Chưa có lời dịch.'));
          break;
        case 'Từ khoá':
          children.add(_KeywordList(keywords: exp?.keywords ?? []));
          break;
        case 'Dịch câu hỏi':
          // Với Part 5, lấy bản dịch chính của câu hỏi
          final text = isPart5 ? (exp?.translation ?? 'Chưa có bản dịch.') : _joinList(exp?.questionsTranslation ?? [], false);
          children.add(_ScrollableText(text: text));
          break;
        case 'Bài mẫu':
          children.add(_ScrollableText(text: _joinList(_sampleAnswers(exp), isPart5)));
          break;
        case 'Dịch bài mẫu':
          children.add(_ScrollableText(text: _joinList(_sampleAnswersTranslation(exp), isPart5)));
          break;
        default:
          children.add(const _ScrollableText(text: 'Đang cập nhật dữ liệu...'));
      }
    }

    return SizedBox(
      height: 250,
      child: TabBarView(controller: _tabController!, children: children),
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
