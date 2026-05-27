import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/writing_question.dart';
import '../../../../data/repositories/writing_repository.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../shared/practice_dialogs.dart';

class PictureDescriptionTestScreen extends StatefulWidget {
  final int questionLimit;

  const PictureDescriptionTestScreen({super.key, required this.questionLimit});

  @override
  State<PictureDescriptionTestScreen> createState() =>
      _PictureDescriptionTestScreenState();
}

class _PictureDescriptionTestScreenState
    extends State<PictureDescriptionTestScreen> {
  late WritingRepository _repository;
  late List<WritingQuestion> _questions;
  int _currentQ = 0;
  bool _isLoading = true;
  String? _error;
  bool _showExplanation = false;
  double _fontSize = 14.0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = WritingRepository();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final allQuestions = await _repository.getPracticeByTaskType(
        'write_sentence',
      );
      setState(() {
        _questions = allQuestions.take(widget.questionLimit).toList();
        _currentQ = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQ < _questions.length - 1) {
        _currentQ++;
        _controller.clear();
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Đang tải...'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Lỗi'),
        body: Center(child: Text('Không có câu hỏi: ${_error ?? ""}')),
      );
    }

    final currentQuestion = _questions[_currentQ];
    final questionNumber = _currentQ + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Câu $questionNumber',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.appBarFg,
              size: 22,
            ),
            onPressed: () => showWritingReportDialog(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.appBarFg,
              size: 22,
            ),
            onPressed: () => showWritingSettingsDialog(
              context,
              fontSize: _fontSize,
              onFontSizeChanged: (v) => setState(() => _fontSize = v),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.appBarFg,
              size: 22,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Explanation button
          GestureDetector(
            onTap: () => setState(() => _showExplanation = !_showExplanation),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: const Text(
                'Giải thích',
                style: TextStyle(
                  color: AppColors.appBarFg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Progress Strip
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Part 1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _questions.isNotEmpty
                              ? (_currentQ + 1) / _questions.length
                              : 0,
                          backgroundColor: AppColors.primaryLighter,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_currentQ + 1}/${_questions.length}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      currentQuestion.promptImageUrl ??
                          'https://via.placeholder.com/600x400?text=No+Image',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentQuestion.givenWords.isNotEmpty
                          ? currentQuestion.givenWords.join(' / ')
                          : 'Sử dụng các từ cho trước',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Mô tả hình ảnh của bạn...',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: _fontSize,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: _fontSize,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          if (_showExplanation) _buildExplanationPanel(currentQuestion),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Thoát',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentQ >= _questions.length - 1 ? 'Xong' : 'Tiếp',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationPanel(WritingQuestion question) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: _WritingExplanationPanel(
        question: question,
        taskType: question.taskType,
        onClose: () => setState(() => _showExplanation = false),
      ),
    );
  }
}

// ── Explanation panel ─────────────────────────────────────────────────────────

class _WritingExplanationPanel extends StatefulWidget {
  const _WritingExplanationPanel({
    required this.question,
    required this.taskType,
    required this.onClose,
  });

  final WritingQuestion question;
  final String taskType;
  final VoidCallback onClose;

  @override
  State<_WritingExplanationPanel> createState() =>
      _WritingExplanationPanelState();
}

class _WritingExplanationPanelState extends State<_WritingExplanationPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    // Always show 2 tabs for picture description
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
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
          SizedBox(
            height: 200,
            child: TabBarView(controller: _tab, children: _buildTabContents()),
          ),
        ],
      ),
    );
  }

  List<Tab> _buildTabs() {
    return const [Tab(text: 'Bài mẫu'), Tab(text: 'Dịch bài mẫu')];
  }

  List<Widget> _buildTabContents() {
    return [
      _ExplanationText(widget.question.sampleAnswer ?? 'Không có bài mẫu'),
      _ExplanationText(
        widget.question.sampleAnswerTranslation ?? 'Không có bản dịch',
      ),
    ];
  }
}

class _ExplanationText extends StatelessWidget {
  const _ExplanationText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.7),
      ),
    );
  }
}
