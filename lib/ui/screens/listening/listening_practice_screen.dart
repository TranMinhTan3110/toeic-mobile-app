import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/answer_card.dart';
import '../../widgets/common/audio_player_bar.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/listening_data.dart';
import '../../../providers/listening_provider.dart';
import '../../../data/models/listening_question.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'package:audioplayers/audioplayers.dart';

/// Màn hình làm bài nghe – dùng chung cho cả 4 part.
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
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  int _currentIdx = 0;
  String? _selectedKey;
  String? _submittedKey;
  bool _showExplanation = false;
  bool _isPlaying = false;
  double _audioProgress = 0.0;

  // Settings state
  double _speed = 1.0;
  bool _autoPlay = true;
  bool _showTranscriptSetting = false;

  // Part 3/4: sub-question answers
  final _subAnswers = <int, String?>{};
  final _subSubmitted = <int, String?>{};

  int get partNumber => widget.part.partNumber;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
          if (_duration.inMilliseconds > 0) {
            _audioProgress =
                _position.inMilliseconds / _duration.inMilliseconds;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListeningProvider>().fetchQuestionsByPart(
        widget.part.partNumber,
        widget.questionCount,
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String? _lastAudioUrl;

  void _initAudio(String? url) {
    if (url == null || url == _lastAudioUrl) return;
    _lastAudioUrl = url;

    setState(() {
      _duration = Duration.zero;
      _position = Duration.zero;
      _audioProgress = 0.0;
    });

    _audioPlayer
        .setSource(UrlSource(url))
        .then((_) {
          if (_autoPlay) {
            _audioPlayer.resume();
          }
        })
        .catchError((e) {
          debugPrint('Error setting audio source: $e');
        });
  }

  Future<void> _playAudio(String url) async {
    try {
      if (_audioPlayer.source == null ||
          (_audioPlayer.source as UrlSource).url != url) {
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

  void _nextQuestion() {
    final provider = context.read<ListeningProvider>();
    final total = partNumber <= 2
        ? provider.questions.length
        : provider.groups.length;

    _audioPlayer.stop();

    setState(() {
      if (_currentIdx < total - 1) {
        _currentIdx++;
        _selectedKey = null;
        _submittedKey = null;
        _showExplanation = false;
        _audioProgress = 0.0;
        _position = Duration.zero;
        _duration = Duration.zero;
        _isPlaying = false;
        _lastAudioUrl = null; // Reset to force reload for next question
        _subAnswers.clear();
        _subSubmitted.clear();
      } else {
        Navigator.pop(context);
      }
    });
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return '0:00';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _submit() => setState(() => _submittedKey = _selectedKey);

  @override
  Widget build(BuildContext context) {
    return Consumer<ListeningProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.errorMessage != null) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Lỗi'),
            body: Center(child: Text(provider.errorMessage!)),
          );
        }

        final total = partNumber <= 2
            ? provider.questions.length
            : provider.groups.length;
        if (total == 0) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Không có dữ liệu'),
            body: const Center(
              child: Text('Không tìm thấy câu hỏi cho phần này.'),
            ),
          );
        }

        String? currentAudioUrl;
        if (partNumber <= 2) {
          currentAudioUrl = provider.questions[_currentIdx].audioUrl;
        } else {
          currentAudioUrl = provider.groups[_currentIdx].audioUrl;
        }

        // Tải metadata audio ngay khi có URL để lấy thời gian tổng (Duration)
        if (currentAudioUrl != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _initAudio(currentAudioUrl),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              AudioPlayerBar(
                isPlaying: _isPlaying,
                progress: _audioProgress,
                elapsed: _formatDuration(_position),
                total: _formatDuration(_duration),
                onPlayPause: () => _togglePlayPause(currentAudioUrl),
                onRewind: _rewind,
                onForward: _forward,
                onSeek: (value) {
                  final newPos = Duration(
                    milliseconds: (value * _duration.inMilliseconds).toInt(),
                  );
                  _audioPlayer.seek(newPos);
                },
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: Stack(
                  children: [
                    _buildContent(provider, total),
                    if (_showExplanation) _buildExplanationPanel(provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  CustomAppBar _buildAppBar() {
    return CustomAppBar(
      title: 'Câu ${_currentIdx + 1}',
      actions: [
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

  Widget _buildContent(ListeningProvider provider, int total) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _QuestionStrip(
          current: _currentIdx + 1,
          total: total,
          partNumber: partNumber,
        ),
        if (partNumber == 1) _buildPart1(provider.questions[_currentIdx]),
        if (partNumber == 2) _buildPart2(provider.questions[_currentIdx]),
        if (partNumber == 3)
          _buildPart3or4(provider.groups[_currentIdx], withImage: true),
        if (partNumber == 4)
          _buildPart3or4(provider.groups[_currentIdx], withImage: false),
        if (_submittedKey != null ||
            (partNumber >= 3 &&
                _allSubSubmittedFor(
                  provider.groups[_currentIdx].questions.length,
                )))
          _NextButton(onTap: _nextQuestion)
        else if (_selectedKey != null && partNumber <= 2)
          _SubmitButton(onTap: _submit),
      ],
    );
  }

  bool _allSubSubmittedFor(int questionCount) {
    if (questionCount <= 0) return false;
    for (var i = 0; i < questionCount; i++) {
      if (_subSubmitted[i] == null) return false;
    }
    return true;
  }

  Widget _buildPart1(ListeningQuestion q) {
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
              if (q.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: Image.network(
                    q.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_rounded,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        AnswerCard(
          options: PracticeOptionParser.toAnswerOptions(q.options),
          selectedKey: _selectedKey,
          correctKey: _submittedKey != null
              ? PracticeOptionParser.normalizeCorrectKey(
                  q.correctAnswer,
                  options: q.options,
                )
              : null,
          onSelect: _submittedKey == null
              ? (k) => setState(() => _selectedKey = k)
              : null,
          title: '',
        ),
      ],
    );
  }

  Widget _buildPart2(ListeningQuestion q) {
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
          options: PracticeOptionParser.toAnswerOptions(q.options),
          selectedKey: _selectedKey,
          correctKey: _submittedKey != null
              ? PracticeOptionParser.normalizeCorrectKey(
                  q.correctAnswer,
                  options: q.options,
                )
              : null,
          onSelect: _submittedKey == null
              ? (k) => setState(() => _selectedKey = k)
              : null,
          title: '',
        ),
      ],
    );
  }

  Widget _buildPart3or4(ListeningGroup group, {required bool withImage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (withImage && group.imageUrl != null)
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
              child: Image.network(
                group.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_rounded,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ...List.generate(group.questions.length, (i) {
          final q = group.questions[i];
          return _SubQuestion(
            number: i + 1,
            questionText: q.questionText ?? '',
            options: PracticeOptionParser.toAnswerOptions(q.options),
            selectedKey: _subAnswers[i],
            submittedKey: _subSubmitted[i],
            correctKey: PracticeOptionParser.normalizeCorrectKey(
              q.correctAnswer,
              options: q.options,
            ),
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

  Widget _buildExplanationPanel(ListeningProvider provider) {
    String script = '';
    String explanation = '';
    String explanationVi = '';

    if (partNumber <= 2) {
      final q = provider.questions[_currentIdx];
      script = q.script ?? 'Không có phụ đề cho câu hỏi này.';
      explanation = q.explanation ?? 'Không có lời giải cho câu hỏi này.';
      explanationVi = q.explanationVi ?? 'Không có lời dịch cho câu hỏi này.';
    } else {
      final group = provider.groups[_currentIdx];
      script =
          group.script ??
          group.passageText ??
          'Không có phụ đề cho bài nghe này.';

      if (group.questions.isNotEmpty) {
        explanation = group.questions
            .map((q) {
              final idx = group.questions.indexOf(q) + 1;
              final qText = q.questionText != null
                  ? ' (${q.questionText})'
                  : '';
              return 'Câu $idx$qText:\n${q.explanation ?? "Chưa có lời giải."}';
            })
            .join('\n\n---\n\n');

        explanationVi = group.questions
            .map((q) {
              final idx = group.questions.indexOf(q) + 1;
              final qText = q.questionText != null
                  ? ' (${q.questionText})'
                  : '';
              return 'Câu $idx$qText:\n${q.explanationVi ?? "Chưa có lời dịch."}';
            })
            .join('\n\n---\n\n');
      } else {
        explanation = 'Không có lời giải cho bài nghe này.';
        explanationVi = 'Không có lời dịch cho bài nghe này.';
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
}

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
                value: total > 0 ? current / total : 0,
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
                      Tab(text: 'Lời giải'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
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
