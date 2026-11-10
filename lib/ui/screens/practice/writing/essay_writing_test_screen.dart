import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/writing_history_item.dart';
import '../../../../data/models/writing_question.dart';
import '../../../../data/repositories/writing_repository.dart';
import '../../../../providers/writing_provider.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/cards/essay_prompt_card.dart';
import '../../../shared/practice_dialogs.dart';
import 'writing_history_detail_screen.dart';

class EssayWritingTestScreen extends StatefulWidget {
  final int questionLimit;
  final String? retryHistoryId;

  const EssayWritingTestScreen({
    super.key,
    required this.questionLimit,
    this.retryHistoryId,
  });

  @override
  State<EssayWritingTestScreen> createState() => _EssayWritingTestScreenState();
}

class _EssayWritingTestScreenState extends State<EssayWritingTestScreen> {
  late WritingRepository _repository;
  late List<WritingQuestion> _questions;
  int _currentQ = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  bool _showExplanation = false;
  double _fontSize = 14.0;
  final TextEditingController _controller = TextEditingController();

  /// Store all answers in a map: questionId -> answer
  final Map<String, String> _allAnswers = {};
  final Map<String, int> _wordCounts = {};

  @override
  void initState() {
    super.initState();
    _repository = WritingRepository();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final allQuestions = await _repository.getPracticeByTaskType(
        'opinion_essay',
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  /// Save current answer, evaluate with AI and move to next question
  Future<void> _saveAndNextQuestion() async {
    final answer = _controller.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng viết câu trả lời trước khi tiếp tục.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<WritingProvider>();
    final evaluation = await provider.evaluateAnswer(
      _questions[_currentQ].id,
      answer,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (evaluation != null) {
      // Store answer and stats in the map
      _allAnswers[_questions[_currentQ].id] = answer;
      _wordCounts[_questions[_currentQ].id] = answer.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

      // Show beautiful AI feedback modal bottom sheet
      await _showEvaluationResult(evaluation);

      // Move to next question or save session if completed
      if (_currentQ < _questions.length - 1) {
        setState(() {
          _currentQ++;
          _controller.clear();
        });
      } else {
        // Last question - save the entire session
        await _saveSession();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Không chấm điểm được bằng AI. Vui lòng thử lại.')),
      );
    }
  }

  Future<void> _showEvaluationResult(dynamic result) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Kết quả câu hỏi ${widget.questionLimit > 1 ? (_currentQ + 1) : 1}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  result.overallScore.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Criteria scores progress bars
                    const Text(
                      'Tiêu chí đánh giá:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    ...result.criteriaScores.entries.map<Widget>((entry) {
                      final key = entry.key;
                      final val = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                Text('${val.toStringAsFixed(1)}/10', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: val / 10.0,
                                minHeight: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  val >= 7.0 ? AppColors.green : (val >= 5.0 ? Colors.orange : Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),

                    // 2. Feedback general
                    const Text(
                      'Phản hồi từ giám khảo AI:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.feedback,
                      style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // 3. Corrections
                    if (result.correctionsVi.isNotEmpty) ...[
                      const Text(
                        'Phân tích lỗi & Sửa lại:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Text(
                          result.correctionsVi,
                          style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Suggested Improvement
                    if (result.suggestedImprovement.isNotEmpty) ...[
                      const Text(
                        'Bài viết đề xuất cải tiến:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.green),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.green.withOpacity(0.2)),
                        ),
                        child: Text(
                          result.suggestedImprovement,
                          style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Save the entire session with all answers (only called once at the end)
  Future<void> _saveSession() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final lastEval = context.read<WritingProvider>().lastEvaluation;
      final overallScoreInt = lastEval != null ? lastEval.overallScore.round() : 0;
      final writingAiFeedback = lastEval != null
          ? WritingAiFeedback(
              grammarScore: lastEval.criteriaScores['Ngữ pháp']?.round() ?? lastEval.criteriaScores['Grammar']?.round() ?? 0,
              vocabularyScore: lastEval.criteriaScores['Từ vựng']?.round() ?? lastEval.criteriaScores['Vocabulary']?.round() ?? 0,
              cohesionScore: lastEval.criteriaScores['Bố cục & Liên kết']?.round() ?? lastEval.criteriaScores['Cohesion']?.round() ?? 0,
              correctionsVi: lastEval.correctionsVi,
              suggestedImprovement: lastEval.suggestedImprovement,
            )
          : null;

      final sessionId = await context.read<WritingProvider>().saveSession(
        historyId: widget.retryHistoryId,
        questionIds: _questions.map((q) => q.id).toList(),
        answers: _allAnswers,
        sessionType: 'practice',
        taskNumber: 3,
        taskType: 'opinion_essay',
        questionCount: _questions.length,
        aiScore: overallScoreInt,
        aiFeedback: writingAiFeedback,
      );

      if (mounted) {
        if (sessionId == null || sessionId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không lưu được phiên luyện tập.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu phiên luyện tập thành công!')),
          );

          final resultItem = WritingHistoryItem(
            id: sessionId,
            userId: '',
            questionId: _questions.first.id,
            sessionType: 'practice',
            userAnswer: _allAnswers[_questions.first.id] ?? '',
            submittedAt: DateTime.now(),
            taskNumber: 3,
            taskType: 'opinion_essay',
            questionCount: _questions.length,
            questionIds: _questions.map((q) => q.id).toList(),
            answers: Map<String, String>.from(_allAnswers),
            aiScore: overallScoreInt,
            aiFeedback: writingAiFeedback,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WritingHistoryDetailScreen(item: resultItem),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
                        'Part 3',
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
                child: EssayPromptCard(
                  prompt: currentQuestion.promptText,
                  fontSize: _fontSize,
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
                    hintText: 'Viết bài luận của bạn...',
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
                  onPressed: _isSubmitting ? null : _saveAndNextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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
    // Always show 2 tabs for essay writing
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
