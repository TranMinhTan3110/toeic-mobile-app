import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/audio_player_bar.dart';
import '../../widgets/practice/answer_card.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/full_test_history_model.dart';
import '../../../data/models/listening_question.dart';
import '../../../core/utils/practice_option_parser.dart';

class FullTestHistorySwipeScreen extends StatefulWidget {
  final FullTestHistoryModel historyItem;
  final List<ListeningQuestion> tabQuestions;
  final Map<String, ListeningGroup> questionGroups;
  final int startIndex;
  final List<ListeningQuestion> allQuestions;

  const FullTestHistorySwipeScreen({
    super.key,
    required this.historyItem,
    required this.tabQuestions,
    required this.questionGroups,
    required this.startIndex,
    required this.allQuestions,
  });

  @override
  State<FullTestHistorySwipeScreen> createState() => _FullTestHistorySwipeScreenState();
}

class _FullTestHistorySwipeScreenState extends State<FullTestHistorySwipeScreen> {
  late PageController _pageController;
  late AudioPlayer _audioPlayer;

  int _currentIdx = 0;
  bool _showExplanation = true; // Always open by default as requested
  bool _isPlaying = false;
  double _audioProgress = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Settings
  double _speed = 1.0;
  bool _autoPlay = true;
  String? _lastAudioUrl;

  @override
  void initState() {
    super.initState();
    _currentIdx = widget.startIndex;
    _pageController = PageController(initialPage: widget.startIndex);
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
          if (_duration.inMilliseconds > 0) {
            _audioProgress = _position.inMilliseconds / _duration.inMilliseconds;
          }
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _audioProgress = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initAudio(String? url) {
    if (url == null || url == _lastAudioUrl) return;
    _lastAudioUrl = url;

    setState(() {
      _duration = Duration.zero;
      _position = Duration.zero;
      _audioProgress = 0.0;
      _isPlaying = false;
    });

    _audioPlayer.setSource(UrlSource(url)).then((_) {
      if (_autoPlay) {
        _audioPlayer.resume();
        _audioPlayer.setPlaybackRate(_speed);
      }
    }).catchError((e) {
      debugPrint('Error setting audio source: $e');
    });
  }

  Future<void> _playAudio(String url) async {
    try {
      if (_audioPlayer.source == null || (_audioPlayer.source as UrlSource).url != url) {
        await _audioPlayer.setSource(UrlSource(url));
      }
      await _audioPlayer.resume();
      await _audioPlayer.setPlaybackRate(_speed);
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void _togglePlayPause(String? url) {
    if (url == null) return;
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      if (_audioProgress >= 0.99) {
        _audioPlayer.seek(Duration.zero);
      }
      _playAudio(url);
    }
  }

  void _rewind() {
    final newPos = _position - const Duration(seconds: 5);
    _audioPlayer.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void _forward() {
    final newPos = _position + const Duration(seconds: 5);
    _audioPlayer.seek(newPos > _duration ? _duration : newPos);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => _LocalSettingsDialog(
        playbackSpeed: _speed,
        autoPlay: _autoPlay,
        onSpeedChanged: (v) {
          setState(() {
            _speed = v;
            _audioPlayer.setPlaybackRate(_speed);
          });
        },
        onAutoPlayChanged: (v) {
          setState(() {
            _autoPlay = v;
          });
        },
      ),
    );
  }

  Widget _buildExplanationPanel() {
    final q = widget.tabQuestions[_currentIdx];
    final group = widget.questionGroups[q.id];

    String script = '';
    String explanation = '';
    String explanationVi = '';

    if (q.part == 1 || q.part == 2 || q.part == 5) {
      script = q.script ?? 'Không có phụ đề cho câu hỏi này.';
      explanation = q.explanation ?? 'Không có lời giải cho câu hỏi này.';
      explanationVi = q.explanationVi ?? 'Không có lời dịch cho câu hỏi này.';
    } else {
      script = group?.script ?? group?.passageText ?? 'Không có phụ đề cho bài đọc/nghe này.';
      if (group != null && group.questions.isNotEmpty) {
        explanation = group.questions
            .map((sq) {
              final idx = group.questions.indexOf(sq) + 1;
              final qText = sq.questionText != null ? ' (${sq.questionText})' : '';
              return 'Câu $idx$qText:\n${sq.explanation ?? "Chưa có lời giải."}';
            })
            .join('\n\n---\n\n');

        explanationVi = group.questions
            .map((sq) {
              final idx = group.questions.indexOf(sq) + 1;
              final qText = sq.questionText != null ? ' (${sq.questionText})' : '';
              return 'Câu $idx$qText:\n${sq.explanationVi ?? "Chưa có lời dịch."}';
            })
            .join('\n\n---\n\n');
      } else {
        explanation = q.explanation ?? 'Không có lời giải cho bài đọc/nghe này.';
        explanationVi = q.explanationVi ?? 'Không có lời dịch cho bài đọc/nghe này.';
      }
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: _ExplanationPanel(
        script: script,
        explanation: explanation,
        explanationVi: explanationVi,
        onClose: () => setState(() => _showExplanation = false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.tabQuestions.length;
    final q = widget.tabQuestions[_currentIdx];
    final group = widget.questionGroups[q.id];

    final globalIdx = widget.allQuestions.indexWhere((x) => x.id == q.id);
    final questionNumber = globalIdx >= 0 ? globalIdx + 1 : _currentIdx + 1;

    String? currentAudioUrl;
    final isListening = q.part <= 4;
    if (isListening) {
      currentAudioUrl = q.part <= 2 ? q.audioUrl : (group?.audioUrl ?? q.audioUrl);
      if (currentAudioUrl != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _initAudio(currentAudioUrl));
      }
    } else {
      _audioPlayer.stop();
      _lastAudioUrl = null;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Câu $questionNumber',
        onBack: () {
          _audioPlayer.stop();
          Navigator.pop(context);
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.error_outline_rounded, color: AppColors.appBarFg, size: 22),
            onPressed: () => showReportDialog(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.appBarFg, size: 22),
            onPressed: _showSettingsDialog,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.appBarFg, size: 22),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          AppBarTextAction(
            label: 'Giải thích',
            onTap: () {
              setState(() {
                _showExplanation = !_showExplanation;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isListening)
            AudioPlayerBar(
              isPlaying: _isPlaying,
              progress: _audioProgress,
              elapsed: _formatDuration(_position),
              total: _formatDuration(_duration),
              onPlayPause: () => _togglePlayPause(currentAudioUrl),
              onRewind: _rewind,
              onForward: _forward,
              onSeek: (value) {
                final newPos = Duration(milliseconds: (value * _duration.inMilliseconds).toInt());
                _audioPlayer.seek(newPos);
              },
            ),
          if (isListening) const Divider(height: 1, color: AppColors.divider),
          _QuestionStrip(
            current: _currentIdx + 1,
            total: total,
            partNumber: q.part,
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: total,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentIdx = idx;
                      _audioPlayer.stop();
                      _lastAudioUrl = null;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final currentQ = widget.tabQuestions[idx];
                    final currentG = widget.questionGroups[currentQ.id];
                    final currentGlobalIdx = widget.allQuestions.indexWhere((x) => x.id == currentQ.id);

                    return _QuestionDetailPage(
                      question: currentQ,
                      group: currentG,
                      historyItem: widget.historyItem,
                      questionNumber: currentGlobalIdx >= 0 ? currentGlobalIdx + 1 : idx + 1,
                    );
                  },
                ),
                if (_showExplanation) _buildExplanationPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionDetailPage extends StatelessWidget {
  final ListeningQuestion question;
  final ListeningGroup? group;
  final FullTestHistoryModel historyItem;
  final int questionNumber;

  const _QuestionDetailPage({
    required this.question,
    required this.group,
    required this.historyItem,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    final part = question.part;
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 320),
      children: [
        if (part == 1) _buildPart1(),
        if (part == 2) _buildPart2(),
        if (part == 3 || part == 4) _buildPart3or4(withImage: part == 3),
        if (part == 5) _buildPart5(),
        if (part == 6 || part == 7) _buildPart6or7(),
      ],
    );
  }

  Widget _buildPart1() {
    return Column(
      children: [
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
              if (question.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: Image.network(
                    question.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  ),
                )
              else
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_rounded, size: 60, color: Colors.grey),
                ),
            ],
          ),
        ),
        AnswerCard(
          options: PracticeOptionParser.toAnswerOptions(question.options),
          selectedKey: historyItem.answers[question.id],
          correctKey: PracticeOptionParser.normalizeCorrectKey(
            question.correctAnswer,
            options: question.options,
          ),
          title: '',
        ),
      ],
    );
  }

  Widget _buildPart2() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
              const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Lắng nghe câu hỏi & chọn đáp án đúng nhất',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        AnswerCard(
          options: PracticeOptionParser.toAnswerOptions(question.options),
          selectedKey: historyItem.answers[question.id],
          correctKey: PracticeOptionParser.normalizeCorrectKey(
            question.correctAnswer,
            options: question.options,
          ),
          title: '',
        ),
      ],
    );
  }

  Widget _buildPart3or4({required bool withImage}) {
    final passage = group?.passageText ?? '';
    final imageUrl = group?.imageUrl ?? question.imageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (withImage && imageUrl != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl),
            ),
          ),
        if (passage.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đoạn hội thoại / Bài nói',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  passage,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
                ),
              ],
            ),
          ),
        _SubQuestionReview(
          number: questionNumber,
          questionText: question.questionText ?? '',
          options: PracticeOptionParser.toAnswerOptions(question.options),
          selectedKey: historyItem.answers[question.id],
          correctKey: PracticeOptionParser.normalizeCorrectKey(
            question.correctAnswer,
            options: question.options,
          ),
        ),
      ],
    );
  }

  Widget _buildPart5() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SelectAnswerHeader(),
              const SizedBox(height: 12),
              Text(
                question.questionText ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        AnswerCard(
          options: PracticeOptionParser.toAnswerOptions(question.options),
          selectedKey: historyItem.answers[question.id],
          correctKey: PracticeOptionParser.normalizeCorrectKey(
            question.correctAnswer,
            options: question.options,
          ),
          title: '',
        ),
      ],
    );
  }

  Widget _buildPart6or7() {
    final passage = group?.passageText ?? group?.script ?? '';
    final imageUrl = group?.imageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl),
            ),
          ),
        if (passage.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đoạn văn (Passage)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  passage,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
                ),
              ],
            ),
          ),
        _SubQuestionReview(
          number: questionNumber,
          questionText: question.questionText ?? '',
          options: PracticeOptionParser.toAnswerOptions(question.options),
          selectedKey: historyItem.answers[question.id],
          correctKey: PracticeOptionParser.normalizeCorrectKey(
            question.correctAnswer,
            options: question.options,
          ),
        ),
      ],
    );
  }
}

class _SubQuestionReview extends StatelessWidget {
  const _SubQuestionReview({
    required this.number,
    required this.questionText,
    required this.options,
    required this.selectedKey,
    required this.correctKey,
  });

  final int number;
  final String questionText;
  final List<AnswerOption> options;
  final String? selectedKey;
  final String? correctKey;

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
                BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
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
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    questionText,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnswerCard(
          options: options,
          selectedKey: selectedKey,
          correctKey: correctKey,
          title: '',
        ),
      ],
    );
  }
}

class _QuestionStrip extends StatelessWidget {
  final int current;
  final int total;
  final int partNumber;

  const _QuestionStrip({
    required this.current,
    required this.total,
    required this.partNumber,
  });

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
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? current / total : 0,
                backgroundColor: AppColors.primaryLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$current/$total',
            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
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
        color: AppColors.primary.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.white, fontSize: 15),
          children: [
            TextSpan(text: 'Select the '),
            TextSpan(text: 'answer', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ExplanationPanel extends StatefulWidget {
  const _ExplanationPanel({
    required this.script,
    required this.explanation,
    required this.explanationVi,
    required this.onClose,
  });

  final String script;
  final String explanation;
  final String explanationVi;
  final VoidCallback onClose;

  @override
  State<_ExplanationPanel> createState() => _ExplanationPanelState();
}

class _ExplanationPanelState extends State<_ExplanationPanel> with SingleTickerProviderStateMixin {
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
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Phụ đề'),
                      Tab(text: 'Lời dịch'),
                      Tab(text: 'Lời giải'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: TabBarView(
              controller: _tab,
              children: [
                _ExplanationText(widget.script),
                _ExplanationText(widget.explanationVi),
                _ExplanationText(widget.explanation),
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

class _LocalSettingsDialog extends StatefulWidget {
  final double playbackSpeed;
  final bool autoPlay;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<bool> onAutoPlayChanged;

  const _LocalSettingsDialog({
    required this.playbackSpeed,
    required this.autoPlay,
    required this.onSpeedChanged,
    required this.onAutoPlayChanged,
  });

  @override
  State<_LocalSettingsDialog> createState() => _LocalSettingsDialogState();
}

class _LocalSettingsDialogState extends State<_LocalSettingsDialog> {
  late double _speed;
  late bool _autoPlay;

  @override
  void initState() {
    super.initState();
    _speed = widget.playbackSpeed;
    _autoPlay = widget.autoPlay;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Cài đặt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tốc độ phát âm thanh',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
                final selected = _speed == speed;
                return GestureDetector(
                  onTap: () => setState(() => _speed = speed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${speed}x',
                      style: TextStyle(
                        color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.play_circle_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Tự động phát', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                ),
                Switch(
                  value: _autoPlay,
                  onChanged: (v) => setState(() => _autoPlay = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSpeedChanged(_speed);
                  widget.onAutoPlayChanged(_autoPlay);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Lưu cài đặt', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
