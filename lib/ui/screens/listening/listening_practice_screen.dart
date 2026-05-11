import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/answer_card.dart';
import '../../widgets/common/audio_player_bar.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/listening_data.dart';

/// Màn hình làm bài nghe – dùng chung cho cả 4 part.
/// Layout thay đổi theo partNumber:
///   Part 1 → có ảnh + 4 đáp án A-D
///   Part 2 → chỉ audio + 3 đáp án A-B-C
///   Part 3 → có ảnh đoạn hội thoại + 3 câu hỏi con
///   Part 4 → như part 3 nhưng không có ảnh
class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({
    super.key,
    required this.part,
    required this.questionCount,
  });

  final ListeningPartInfo part;
  final int questionCount;

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  int _currentQ = 1;
  String? _selectedKey;
  String? _submittedKey;
  bool _showExplanation = false;
  bool _isPlaying = true;
  double _audioProgress = 0.1;

  // Settings state
  double _speed = 1.0;
  bool _autoPlay = true;
  bool _showTranscriptSetting = false;

  // Part 3/4: sub-question index
  int _subQ = 0;
  final _subAnswers = <int, String?>{};
  final _subSubmitted = <int, String?>{};

  int get totalQuestions => widget.questionCount;
  int get partNumber => widget.part.partNumber;

  void _nextQuestion() {
    setState(() {
      if (_currentQ < totalQuestions) {
        _currentQ++;
        _selectedKey = null;
        _submittedKey = null;
        _showExplanation = false;
        _audioProgress = 0.05;
        _isPlaying = true;
        _subQ = 0;
        _subAnswers.clear();
        _subSubmitted.clear();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _submit() => setState(() => _submittedKey = _selectedKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Audio player
          AudioPlayerBar(
            isPlaying: _isPlaying,
            progress: _audioProgress,
            elapsed: '00:02',
            total: partNumber == 1 ? '0:22' : '1:15',
            onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Content
          Expanded(
            child: Stack(
              children: [
                _buildContent(),
                if (_showExplanation) _buildExplanationPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────

  CustomAppBar _buildAppBar() {
    return CustomAppBar(
      title: 'Câu $_currentQ',
      actions: [
        // Dấu chấm than
        IconButton(
          icon: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.appBarFg,
            size: 22,
          ),
          onPressed: () => showReportDialog(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        // Bánh răng
        IconButton(
          icon: const Icon(
            Icons.settings_rounded,
            color: AppColors.appBarFg,
            size: 22,
          ),
          onPressed: () => showPracticeSettingsDialog(
            context,
            playbackSpeed: _speed,
            autoPlay: _autoPlay,
            showTranscript: _showTranscriptSetting,
            onSpeedChanged: (v) => setState(() => _speed = v),
            onAutoPlayChanged: (v) => setState(() => _autoPlay = v),
            onTranscriptChanged: (v) =>
                setState(() => _showTranscriptSetting = v),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        // Yêu thích
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
        // Giải thích
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
    );
  }

  // ── Content by part ──────────────────────────────────────────────────────

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Question number strip
        _QuestionStrip(
          current: _currentQ,
          total: totalQuestions,
          partNumber: partNumber,
        ),

        if (partNumber == 1) _buildPart1(),
        if (partNumber == 2) _buildPart2(),
        if (partNumber == 3) _buildPart3or4(withImage: true),
        if (partNumber == 4) _buildPart3or4(withImage: false),

        // Next / Submit button
        if (_submittedKey != null || (partNumber >= 3 && _allSubSubmitted))
          _NextButton(onTap: _nextQuestion)
        else if (_selectedKey != null && partNumber <= 2)
          _SubmitButton(onTap: _submit),
      ],
    );
  }

  bool get _allSubSubmitted =>
      _subSubmitted.length >= 3 && _subSubmitted.values.every((v) => v != null);

  // ── Part 1: photo + A B C D ──────────────────────────────────────────────

  Widget _buildPart1() {
    return Column(
      children: [
        // "Select the answer" header + image
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SelectAnswerHeader(),
              // Image placeholder
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(0),
                ),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_rounded,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Answers
        AnswerCard(
          options: _part1Options,
          selectedKey: _selectedKey,
          correctKey: _submittedKey != null ? 'A' : null,
          onSelect: _submittedKey == null
              ? (k) => setState(() => _selectedKey = k)
              : null,
          title: '',
        ),
      ],
    );
  }

  static const _part1Options = [
    AnswerOption(key: 'A', text: 'A'),
    AnswerOption(key: 'B', text: 'B'),
    AnswerOption(key: 'C', text: 'C'),
    AnswerOption(key: 'D', text: 'D'),
  ];

  // ── Part 2: audio only + A B C ───────────────────────────────────────────

  Widget _buildPart2() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _SelectAnswerHeader(),
              const SizedBox(height: 12),
              // Audio indicator
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Hãy lắng nghe câu hỏi',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AnswerCard(
          options: _part2Options,
          selectedKey: _selectedKey,
          correctKey: _submittedKey != null ? 'B' : null,
          onSelect: _submittedKey == null
              ? (k) => setState(() => _selectedKey = k)
              : null,
          title: '',
        ),
      ],
    );
  }

  static const _part2Options = [
    AnswerOption(key: 'A', text: 'A'),
    AnswerOption(key: 'B', text: 'B'),
    AnswerOption(key: 'C', text: 'C'),
  ];

  // ── Part 3 & 4: image (opt) + 3 sub-questions ────────────────────────────

  Widget _buildPart3or4({required bool withImage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image for part 3
        if (withImage)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const Center(
                child: Icon(Icons.image_rounded, size: 60, color: Colors.grey),
              ),
            ),
          ),

        // 3 sub-questions
        ...List.generate(3, (i) {
          final qNum = i + 1;
          return _SubQuestion(
            number: qNum,
            questionText: _subQuestionTexts[partNumber == 3 ? 'p3' : 'p4']![i],
            options: [
              AnswerOption(key: 'A', text: _subAnswerTexts[i][0]),
              AnswerOption(key: 'B', text: _subAnswerTexts[i][1]),
              AnswerOption(key: 'C', text: _subAnswerTexts[i][2]),
              AnswerOption(key: 'D', text: _subAnswerTexts[i][3]),
            ],
            selectedKey: _subAnswers[i],
            submittedKey: _subSubmitted[i],
            correctKey: 'A',
            onSelect: _subSubmitted[i] == null
                ? (k) => setState(() => _subAnswers[i] = k)
                : null,
            onSubmit: _subAnswers[i] != null && _subSubmitted[i] == null
                ? () => setState(() => _subSubmitted[i] = _subAnswers[i])
                : null,
          );
        }),
      ],
    );
  }

  static const _subQuestionTexts = {
    'p3': [
      'What are the speakers mainly discussing?',
      'What does the woman suggest?',
      'What will the man do next?',
    ],
    'p4': [
      'What is the talk mainly about?',
      'What problem is mentioned?',
      'What are listeners asked to do?',
    ],
  };

  static const _subAnswerTexts = [
    [
      'A project deadline',
      'A company policy',
      'A new product launch',
      'A client meeting',
    ],
    [
      'Asking for more time',
      'Hiring extra staff',
      'Changing the schedule',
      'Contacting the client',
    ],
    [
      'Send an email',
      'Call a colleague',
      'Review a report',
      'Attend a workshop',
    ],
  ];
}

// ── Sub-question widget (for part 3/4) ──────────────────────────────────────

class _SubQuestion extends StatelessWidget {
  const _SubQuestion({
    required this.number,
    required this.questionText,
    required this.options,
    required this.selectedKey,
    required this.submittedKey,
    required this.correctKey,
    required this.onSelect,
    required this.onSubmit,
  });

  final int number;
  final String questionText;
  final List<AnswerOption> options;
  final String? selectedKey;
  final String? submittedKey;
  final String correctKey;
  final ValueChanged<String>? onSelect;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    questionText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnswerCard(
          options: options,
          selectedKey: selectedKey,
          correctKey: submittedKey != null ? correctKey : null,
          onSelect: onSelect,
          title: '',
        ),
        if (selectedKey != null && submittedKey == null && onSubmit != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Shared small widgets ─────────────────────────────────────────────────────

class _QuestionStrip extends StatelessWidget {
  const _QuestionStrip({
    required this.current,
    required this.total,
    required this.partNumber,
  });
  final int current, total, partNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Part $partNumber',
              style: const TextStyle(
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
                value: current / total,
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
            '$current/$total',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectAnswerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8860B).withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.white, fontSize: 15),
          children: [
            TextSpan(text: 'Select the '),
            TextSpan(
              text: 'answer',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Xác nhận',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text(
            'Câu tiếp theo',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

// ── Explanation panel ─────────────────────────────────────────────────────────

extension on _ListeningPracticeScreenState {
  Widget _buildExplanationPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: _ExplanationPanel(
        onClose: () => setState(() => _showExplanation = false),
      ),
    );
  }
}

class _ExplanationPanel extends StatefulWidget {
  const _ExplanationPanel({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_ExplanationPanel> createState() => _ExplanationPanelState();
}

class _ExplanationPanelState extends State<_ExplanationPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
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
                    tabs: const [
                      Tab(text: 'Phụ đề'),
                      Tab(text: 'Lời dịch'),
                      Tab(text: 'Từ khoá'),
                    ],
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
            child: TabBarView(
              controller: _tab,
              children: [
                _ExplanationText(
                  'A. They\'re folding some papers\n'
                  'B. They\'re putting a picture in a frame\n'
                  'C. They\'re studying a drawing\n'
                  'D. They\'re closing a window',
                ),
                _ExplanationText(
                  'A. Họ đang gấp một số tờ giấy\n'
                  'B. Họ đang đặt một bức tranh vào khung\n'
                  'C. Họ đang nghiên cứu một bản vẽ\n'
                  'D. Họ đang đóng cửa sổ',
                ),
                _ExplanationText(
                  '🔑 fold: gấp\n'
                  '🔑 picture: bức tranh\n'
                  '🔑 frame: khung\n'
                  '🔑 study: nghiên cứu\n'
                  '🔑 window: cửa sổ',
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
