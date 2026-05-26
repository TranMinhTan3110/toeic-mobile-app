import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/answer_card.dart';
import '../../widgets/common/audio_player_bar.dart';
import '../../shared/practice_dialogs.dart';
import '../../../providers/exam_provider.dart';
import '../../../data/models/listening_question.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'package:audioplayers/audioplayers.dart';

class ExamTakingScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const ExamTakingScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  int _currentIdx = 0;
  String? _selectedKey;
  bool _isPlaying = false;
  double _audioProgress = 0.0;

  // Settings state
  double _speed = 1.0;
  bool _autoPlay = true;
  bool _autoAdvance = true;
  double _fontSize = 14.0;

  // Part 3/4: sub-question answers
  final _subAnswers = <int, String?>{};

  // Timer
  Timer? _timer;
  int _remainingSeconds = 120 * 60; // 120 phút

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
        if (_autoAdvance) {
          final total = context.read<ExamProvider>().examItems.length;
          if (_currentIdx < total - 1) {
            _nextQuestion();
          } else {
            _submitExam();
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExamQuestions(widget.examId);
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        // Hết giờ
        _submitExam();
      }
    });
  }

  void _submitExam() {
    // Xử lý nộp bài
    print("Nộp bài thi!");
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
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

    _audioPlayer.setSource(UrlSource(url)).then((_) {
      if (_autoPlay) {
        _audioPlayer.resume();
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

  void _nextQuestion() {
    final provider = context.read<ExamProvider>();
    final total = provider.examItems.length;

    _audioPlayer.stop();

    setState(() {
      if (_currentIdx < total - 1) {
        _currentIdx++;
        _selectedKey = null;
        _audioProgress = 0.0;
        _position = Duration.zero;
        _duration = Duration.zero;
        _isPlaying = false;
        _lastAudioUrl = null;
        _subAnswers.clear();
      } else {
        _submitExam();
      }
    });
  }

  void _prevQuestion() {
    if (_currentIdx > 0) {
      _audioPlayer.stop();
      setState(() {
        _currentIdx--;
        _selectedKey = null;
        _audioProgress = 0.0;
        _position = Duration.zero;
        _duration = Duration.zero;
        _isPlaying = false;
        _lastAudioUrl = null;
        _subAnswers.clear();
      });
    }
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return '0:00';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatTimer(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
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

        final total = provider.examItems.length;
        if (total == 0) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Không có dữ liệu'),
            body: const Center(child: Text('Không tìm thấy dữ liệu đề thi.')),
          );
        }

        final currentItem = provider.examItems[_currentIdx];
        String? currentAudioUrl;
        int partNumber = 1;

        if (currentItem is ListeningQuestion) {
          currentAudioUrl = currentItem.audioUrl;
          partNumber = currentItem.part;
        } else if (currentItem is ListeningGroup) {
          currentAudioUrl = currentItem.audioUrl;
          partNumber = currentItem.part;
        }

        if (currentAudioUrl != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _initAudio(currentAudioUrl));
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
                  final newPos = Duration(milliseconds: (value * _duration.inMilliseconds).toInt());
                  _audioPlayer.seek(newPos);
                },
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 300) {
                      _prevQuestion();
                    } else if (details.primaryVelocity! < -300) {
                      final total = provider.examItems.length;
                      if (_currentIdx < total - 1) {
                        _nextQuestion();
                      } else {
                        _submitExam();
                      }
                    }
                  },
                  child: _buildContent(currentItem, provider.totalQuestions, partNumber, provider.questionNumbers[_currentIdx]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => _ExamSettingsDialog(
        initialAutoAdvance: _autoAdvance,
        initialFontSize: _fontSize,
        onSave: (autoAdvance, fontSize) {
          setState(() {
            _autoAdvance = autoAdvance;
            _fontSize = fontSize;
          });
        },
      ),
    );
  }

  CustomAppBar _buildAppBar() {
    return CustomAppBar(
      title: widget.examTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: _showSettingsDialog,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                _formatTimer(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(dynamic currentItem, int totalQuestions, int partNumber, int startNumber) {
    int count = currentItem is ListeningGroup ? currentItem.questions.length : 1;
    String displayCurrent = count > 1 ? '$startNumber-${startNumber + count - 1}' : '$startNumber';
    
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _QuestionStrip(currentDisplay: displayCurrent, currentNumber: startNumber, total: totalQuestions, partNumber: partNumber),
        if (currentItem is ListeningQuestion)
          partNumber == 1 ? _buildPart1(currentItem, _fontSize) : _buildPart2(currentItem, _fontSize),
        if (currentItem is ListeningGroup)
          _buildPart3or4(currentItem, withImage: partNumber == 3, startNumber: startNumber, fontSize: _fontSize),
      ],
    );
  }

  Widget _buildPart1(ListeningQuestion q, double fontSize) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SelectAnswerHeader(),
              if (q.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  child: Image.network(
                    q.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
          options: PracticeOptionParser.toAnswerOptions(q.options),
          selectedKey: _selectedKey,
          correctKey: null,
          onSelect: (k) => setState(() => _selectedKey = k),
          title: '',
          fontSize: fontSize,
        ),
      ],
    );
  }

  Widget _buildPart2(ListeningQuestion q, double fontSize) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3)),
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
                    Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Hãy lắng nghe câu hỏi',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
          correctKey: null,
          onSelect: (k) => setState(() => _selectedKey = k),
          title: '',
          fontSize: fontSize,
        ),
      ],
    );
  }

  Widget _buildPart3or4(ListeningGroup group, {required bool withImage, required int startNumber, required double fontSize}) {
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
                BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                group.imageUrl!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ...List.generate(group.questions.length, (i) {
          final q = group.questions[i];
          return _SubQuestion(
            number: startNumber + i,
            questionText: q.questionText ?? '',
            options: PracticeOptionParser.toAnswerOptions(q.options),
            selectedKey: _subAnswers[i],
            onSelect: (k) => setState(() => _subAnswers[i] = k),
            fontSize: fontSize,
          );
        }),
      ],
    );
  }
}

class _SubQuestion extends StatelessWidget {
  const _SubQuestion({
    required this.number,
    required this.questionText,
    required this.options,
    required this.selectedKey,
    required this.onSelect,
    required this.fontSize,
  });

  final int number;
  final String questionText;
  final List<AnswerOption> options;
  final String? selectedKey;
  final ValueChanged<String>? onSelect;
  final double fontSize;

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
                    child: Text('$number',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(questionText,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: fontSize, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
        AnswerCard(
          options: options,
          selectedKey: selectedKey,
          correctKey: null,
          onSelect: onSelect,
          title: '',
          fontSize: fontSize,
        ),
      ],
    );
  }
}

class _QuestionStrip extends StatelessWidget {
  const _QuestionStrip({required this.currentDisplay, required this.currentNumber, required this.total, required this.partNumber});
  final String currentDisplay;
  final int currentNumber, total, partNumber;

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
                value: total > 0 ? currentNumber / total : 0,
                backgroundColor: AppColors.primaryLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$currentDisplay/$total',
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
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
            TextSpan(text: 'answer', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ExamSettingsDialog extends StatefulWidget {
  const _ExamSettingsDialog({
    required this.initialAutoAdvance,
    required this.initialFontSize,
    required this.onSave,
  });

  final bool initialAutoAdvance;
  final double initialFontSize;
  final Function(bool, double) onSave;

  @override
  State<_ExamSettingsDialog> createState() => _ExamSettingsDialogState();
}

class _ExamSettingsDialogState extends State<_ExamSettingsDialog> {
  late bool _autoAdvance;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _autoAdvance = widget.initialAutoAdvance;
    _fontSize = widget.initialFontSize;
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
            // Header
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
                const Text('Cài đặt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Auto advance
            _SwitchRow(
              icon: Icons.skip_next_rounded,
              label: 'Tự động chuyển câu',
              value: _autoAdvance,
              onChanged: (v) => setState(() => _autoAdvance = v),
            ),
            const Divider(color: AppColors.divider, height: 20),

            // Font size
            Row(
              children: [
                const Icon(Icons.format_size_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Cỡ chữ', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                  onPressed: _fontSize > 10 ? () => setState(() => _fontSize -= 2) : null,
                ),
                Text('${_fontSize.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  onPressed: _fontSize < 24 ? () => setState(() => _fontSize += 2) : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_autoAdvance, _fontSize);
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
