import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/writing_history_item.dart';
import '../../../../data/models/writing_question.dart';
import '../../../../data/repositories/writing_repository.dart';

class WritingHistoryOverviewScreen extends StatelessWidget {
  const WritingHistoryOverviewScreen({super.key, required this.item});

  final WritingHistoryItem item;

  List<MapEntry<String, String>> get _answers {
    if (item.questionIds.isNotEmpty) {
      return item.questionIds
          .map((id) => MapEntry(id, item.answers[id] ?? ''))
          .toList();
    }
    if (item.answers.isNotEmpty) return item.answers.entries.toList();
    return [
      MapEntry(
        item.questionId.isNotEmpty ? item.questionId : 'Câu 1',
        item.userAnswer,
      ),
    ];
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
    return part > 0 ? 'Part $part: $label' : label;
  }

  @override
  Widget build(BuildContext context) {
    final answers = _answers;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tổng quan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: const SizedBox(),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _partTitle,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: answers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final answer = answers[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WritingHistoryReviewScreen(
                          item: item,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Câu ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                answer.value.trim().isEmpty
                                    ? '(Không trả lời)'
                                    : answer.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: answer.value.trim().isEmpty
                                      ? AppColors.textHint
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: AppColors.primary,
            child: const Text(
              'Ấn vào từng câu để xem bài viết chi tiết',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WritingHistoryReviewScreen extends StatefulWidget {
  const WritingHistoryReviewScreen({
    super.key,
    required this.item,
    this.initialIndex = 0,
  });

  final WritingHistoryItem item;
  final int initialIndex;

  @override
  State<WritingHistoryReviewScreen> createState() =>
      _WritingHistoryReviewScreenState();
}

class _WritingHistoryReviewScreenState
    extends State<WritingHistoryReviewScreen> {
  late final PageController _pageController;
  late final List<MapEntry<String, String>> _answers;
  final WritingRepository _repository = WritingRepository();
  final Map<String, WritingQuestion> _questionsById = {};
  int _currentIndex = 0;
  bool _showPanel = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _answers = _orderedAnswers(widget.item);
    _currentIndex = widget.initialIndex.clamp(0, _answers.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _loadQuestions();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _showPanel = true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> _orderedAnswers(WritingHistoryItem item) {
    if (item.questionIds.isNotEmpty) {
      return item.questionIds
          .map((id) => MapEntry(id, item.answers[id] ?? ''))
          .toList();
    }
    if (item.answers.isNotEmpty) return item.answers.entries.toList();
    return [
      MapEntry(
        item.questionId.isNotEmpty ? item.questionId : 'Câu 1',
        item.userAnswer,
      ),
    ];
  }

  Future<void> _loadQuestions() async {
    for (final answer in _answers) {
      try {
        final question = await _repository.getById(answer.key);
        _questionsById[answer.key] = question;
      } catch (_) {
        // Keep review usable even if the original question cannot be loaded.
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questionsById[_answers[_currentIndex].key];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              const LinearProgressIndicator(
                value: 1,
                minHeight: 4,
                backgroundColor: AppColors.primaryLighter,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _answers.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final answer = _answers[index];
                    final question = _questionsById[answer.key];
                    return _buildPageContent(question, answer);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _WritingExplanationPanel(
              isVisible: _showPanel && !_isLoading,
              question: currentQuestion,
              taskType: widget.item.taskType,
              onClose: () => setState(() => _showPanel = false),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Câu ${_currentIndex + 1}/${_answers.length}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.report_problem_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, color: Colors.white),
        ),
        TextButton(
          onPressed: () => setState(() => _showPanel = !_showPanel),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(right: 12),
          ),
          child: const Text(
            'Giải thích',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent(
    WritingQuestion? question,
    MapEntry<String, String> answer,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCard(question, answer.key),
          const SizedBox(height: 24),
          const Text(
            'Câu trả lời của bạn:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              answer.value.trim().isEmpty
                  ? '(Chưa có câu trả lời)'
                  : answer.value,
              textAlign: answer.value.trim().isEmpty
                  ? TextAlign.center
                  : TextAlign.left,
              style: TextStyle(
                color: answer.value.trim().isEmpty
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontSize: answer.value.trim().isEmpty ? 19 : 15,
                fontWeight: answer.value.trim().isEmpty
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontStyle: answer.value.trim().isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
                height: 1.7,
              ),
            ),
          ),
          _buildAiFeedbackSection(),
          const SizedBox(height: 360),
        ],
      ),
    );
  }

  Widget _buildAiFeedbackSection() {
    final aiFeedback = widget.item.aiFeedback;
    if (aiFeedback == null || !widget.item.hasAiFeedback) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Nhận xét chi tiết từ AI:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        // Corrections Card (Phân tích lỗi sai)
        if (aiFeedback.correctionsVi?.isNotEmpty == true) ...[
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
                  aiFeedback.correctionsVi!,
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
        if (aiFeedback.suggestedImprovement?.isNotEmpty == true) ...[
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
                  aiFeedback.suggestedImprovement!,
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

  Widget _buildQuestionCard(WritingQuestion? question, String questionId) {
    if (question == null) {
      return _PlainPromptCard(
        label: 'Đề bài',
        text: 'Đang tải dữ liệu câu hỏi...\n$questionId',
      );
    }

    switch (question.taskType) {
      case 'write_sentence':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((question.promptImageUrl ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  question.promptImageUrl!,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _imageFallback(),
                ),
              ),
            if ((question.promptImageUrl ?? '').isNotEmpty)
              const SizedBox(height: 12),
            _PlainPromptCard(
              label: 'Từ khoá',
              text: question.givenWords.isNotEmpty
                  ? question.givenWords.join(' / ')
                  : question.promptText,
            ),
          ],
        );
      case 'respond_email':
        return _PlainPromptCard(
          label: 'Email',
          text: question.emailContent?.trim().isNotEmpty == true
              ? question.emailContent!
              : question.promptText,
        );
      case 'opinion_essay':
        return _PlainPromptCard(label: 'Đề bài', text: question.promptText);
      default:
        return _PlainPromptCard(label: 'Đề bài', text: question.promptText);
    }
  }

  Widget _imageFallback() {
    return Container(
      height: 210,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_rounded,
        color: AppColors.textHint,
        size: 42,
      ),
    );
  }
}

class _PlainPromptCard extends StatelessWidget {
  const _PlainPromptCard({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text.trim().isEmpty ? 'Không có nội dung đề bài.' : text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.55,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingExplanationPanel extends StatefulWidget {
  const _WritingExplanationPanel({
    required this.isVisible,
    required this.question,
    required this.taskType,
    required this.onClose,
  });

  final bool isVisible;
  final WritingQuestion? question;
  final String? taskType;
  final VoidCallback onClose;

  @override
  State<_WritingExplanationPanel> createState() =>
      _WritingExplanationPanelState();
}

class _WritingExplanationPanelState extends State<_WritingExplanationPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late int _tabCount;

  @override
  void initState() {
    super.initState();
    _tabCount = _resolveTabCount();
    _tab = TabController(length: _tabCount, vsync: this);
  }

  @override
  void didUpdateWidget(covariant _WritingExplanationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextTabCount = _resolveTabCount();
    if (nextTabCount != _tabCount) {
      _tab.dispose();
      _tabCount = nextTabCount;
      _tab = TabController(length: _tabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      offset: widget.isVisible ? Offset.zero : const Offset(0, 1),
      child: Container(
        height: 350,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      tabs: _buildTabs(),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: _buildTabContents(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _resolveTabCount() => _isRespondEmail ? 3 : 2;

  bool get _isRespondEmail {
    final type = widget.question?.taskType ?? widget.taskType;
    return type == 'respond_email';
  }

  List<Tab> _buildTabs() {
    if (_isRespondEmail) {
      return const [
        Tab(text: 'Đề bài'),
        Tab(text: 'Bài mẫu'),
        Tab(text: 'Dịch bài mẫu'),
      ];
    }

    return const [Tab(text: 'Bài mẫu'), Tab(text: 'Dịch bài mẫu')];
  }

  List<Widget> _buildTabContents() {
    if (_isRespondEmail) {
      return [
        _ExplanationText(_promptVietnamese),
        _ExplanationText(_sampleAnswer),
        _ExplanationText(_translation),
      ];
    }

    return [_ExplanationText(_sampleAnswer), _ExplanationText(_translation)];
  }

  String get _sampleAnswer {
    final text = widget.question?.sampleAnswer;
    return text?.trim().isNotEmpty == true
        ? text!
        : 'Chưa có bài mẫu cho câu này.';
  }

  String get _translation {
    final text = widget.question?.sampleAnswerTranslation;
    return text?.trim().isNotEmpty == true
        ? text!
        : 'Chưa có lời dịch cho câu này.';
  }

  String get _promptVietnamese {
    final question = widget.question;
    if (question == null) return 'Đang tải dữ liệu đề bài...';
    if (question.explanationVietnamese?.trim().isNotEmpty == true) {
      return question.explanationVietnamese!;
    }
    return 'Chưa có bản dịch đề bài cho câu này.';
  }
}

class _ExplanationText extends StatelessWidget {
  const _ExplanationText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.55,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
