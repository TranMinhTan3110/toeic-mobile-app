import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/listening_history_model.dart';
import '../../../providers/listening_provider.dart';
import '../../../data/models/listening_question.dart';
import '../../../data/models/listening_data.dart';
import 'listening_practice_screen.dart';
import 'listening_history_overview_screen.dart';

class ListeningHistoryDetailScreen extends StatefulWidget {
  final ListeningHistoryModel historyItem;
  const ListeningHistoryDetailScreen({super.key, required this.historyItem});

  @override
  State<ListeningHistoryDetailScreen> createState() =>
      _ListeningHistoryDetailScreenState();
}

class _ListeningHistoryDetailScreenState
    extends State<ListeningHistoryDetailScreen> {
  bool _isLoadingQuestions = false;

  @override
  void initState() {
    super.initState();
    _preloadQuestionsIfNeeded();
  }

  void _preloadQuestionsIfNeeded() async {
    final provider = context.read<ListeningProvider>();
    final part = widget.historyItem.part;
    final hasCachedData = part <= 2
        ? provider.questionsCache.containsKey(part)
        : provider.groupsCache.containsKey(part);

    if (!hasCachedData) {
      setState(() => _isLoadingQuestions = true);
      try {
        await provider.ensurePartLoaded(part);
      } catch (e) {
        debugPrint('Lỗi preload trong history detail: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoadingQuestions = false);
        }
      }
    }
  }

  ListeningPartInfo? get _partInfo {
    try {
      return ListeningData.parts.firstWhere(
        (p) => p.partNumber == widget.historyItem.part,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final partInfo = _partInfo;
    if (partInfo == null) {
      return const Scaffold(
        body: Center(child: Text('Lỗi: Part không tồn tại')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Lịch sử luyện tập'),
      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoadingQuestions
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải câu hỏi...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : _buildContent(context, partInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ListeningPartInfo partInfo) {
    final provider = context.watch<ListeningProvider>();
    final item = widget.historyItem;

    // Find all questions and groups in this session
    final List<ListeningQuestion> sessionQuestions = [];
    final Map<String, ListeningGroup> questionGroups = {};

    // Search in Questions Cache (Part 1, 2)
    final qCache = provider.questionsCache[item.part] ?? [];
    for (var q in qCache) {
      if (item.selectedAnswers.containsKey(q.id)) {
        sessionQuestions.add(q);
      }
    }

    // Search in Groups Cache (Part 3, 4)
    final gCache = provider.groupsCache[item.part] ?? [];
    for (var group in gCache) {
      for (var q in group.questions) {
        if (item.selectedAnswers.containsKey(q.id)) {
          sessionQuestions.add(q);
          questionGroups[q.id] = group;
        }
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // --- CARD 1: Banner chúc mừng ---
              _buildBannerCard(partInfo),
              const SizedBox(height: 16),

              // --- CARD 2: Kết quả điểm số ---
              _buildScoreDetailsCard(item),
            ],
          ),
        ),

        // --- BUTTONS: CHI TIẾT & LÀM LẠI ---
        _buildBottomControls(partInfo, sessionQuestions, questionGroups),
      ],
    );
  }

  Widget _buildBannerCard(ListeningPartInfo partInfo) {
    final scorePercent = widget.historyItem.percent;
    String comment = 'Hãy cố gắng hơn lần sau nhé!';
    if (scorePercent >= 80) {
      comment = 'Tuyệt vời! Bạn làm rất tốt, hãy duy trì phong độ nhé!';
    } else if (scorePercent >= 50) {
      comment = 'Khá lắm! Tập trung ôn tập kỹ để đạt kết quả tốt hơn nhé.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withRed(220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.yellow,
              size: 48,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Bạn đã hoàn thành bài luyện tập',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Part ${partInfo.partNumber} – ${partInfo.titleVi}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailsCard(ListeningHistoryModel item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gauge vòng tròn
          _AccuracyIndicator(percent: item.percent),
          const SizedBox(width: 24),
          // Thống kê
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KẾT QUẢ ĐẠT ĐƯỢC',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHint,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Đúng: ${item.correctCount}/${item.totalCount} câu',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tỷ lệ chính xác: ${item.percent.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrongQuestionsSection(
    List<ListeningQuestion> wrongQuestions,
    Map<String, ListeningGroup> questionGroups,
  ) {
    if (wrongQuestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: AppColors.green, size: 48),
            SizedBox(height: 12),
            Text(
              'Tuyệt vời! Không có câu hỏi sai',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Bạn đã trả lời đúng 100% các câu hỏi!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.report_problem_rounded,
                color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Danh sách câu hỏi sai (${wrongQuestions.length}):',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...wrongQuestions.map((q) {
          final group = questionGroups[q.id];
          return _buildWrongQuestionCard(q, group);
        }),
      ],
    );
  }

  Widget _buildWrongQuestionCard(ListeningQuestion q, ListeningGroup? group) {
    final item = widget.historyItem;
    final selectedAns = item.selectedAnswers[q.id];
    final correctAns = q.correctAnswer;

    // Mini audio player url
    final audioUrl = group?.audioUrl ?? q.audioUrl;
    final imageUrl = group?.imageUrl ?? q.imageUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audio Player (nếu có)
          if (audioUrl != null && audioUrl.isNotEmpty) ...[
            MiniAudioPlayer(audioUrl: audioUrl),
            const SizedBox(height: 12),
          ],

          // Image (nếu có)
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: AppColors.textHint, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Passage/Group Script (Part 3/4)
          if (group != null &&
              group.passageText != null &&
              group.passageText!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                group.passageText!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Question Text
          Text(
            q.questionText ?? 'Nghe audio và chọn đáp án đúng:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Options cards
          ...List.generate(q.options.length, (idx) {
            final optionText = q.options[idx];
            final optionKey = String.fromCharCode(65 + idx); // A, B, C, D

            final isSelected = selectedAns == optionKey;
            final isCorrect = correctAns == optionKey;

            Color tileColor = AppColors.surface;
            Color borderColor = AppColors.divider;
            Widget? suffixIcon;

            if (isCorrect) {
              tileColor = AppColors.green.withOpacity(0.12);
              borderColor = AppColors.green;
              suffixIcon = const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 20);
            } else if (isSelected) {
              tileColor = Colors.red.withOpacity(0.08);
              borderColor = Colors.red;
              suffixIcon =
                  const Icon(Icons.cancel_rounded, color: Colors.red, size: 20);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: tileColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.green
                          : (isSelected ? Colors.red : AppColors.divider),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        optionKey,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: (isCorrect || isSelected)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (suffixIcon != null) suffixIcon,
                ],
              ),
            );
          }),

          // Lời giải (Explanation)
          const SizedBox(height: 12),
          const Divider(),
          _buildExplanationSection(q, group),
        ],
      ),
    );
  }

  Widget _buildExplanationSection(ListeningQuestion q, ListeningGroup? group) {
    final script = group?.script ?? q.script;
    final explanation = q.explanationVi ?? q.explanation?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (script != null && script.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text(
            'Phụ đề / Script:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            script,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (explanation != null && explanation.isNotEmpty) ...[
          const Text(
            'Lời giải chi tiết:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomControls(
    ListeningPartInfo partInfo,
    List<ListeningQuestion> sessionQuestions,
    Map<String, ListeningGroup> questionGroups,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListeningHistoryOverviewScreen(
                      historyItem: widget.historyItem,
                      sessionQuestions: sessionQuestions,
                      questionGroups: questionGroups,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Chi tiết',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Redo Practice
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListeningPracticeScreen(
                      part: partInfo,
                      questionCount: widget.historyItem.totalCount,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Làm lại',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyIndicator extends StatelessWidget {
  final double percent;
  const _AccuracyIndicator({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: CircularProgressIndicator(
              value: percent / 100.0,
              strokeWidth: 7,
              backgroundColor: AppColors.divider.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 70
                    ? AppColors.green
                    : (percent >= 40 ? Colors.orange : Colors.red),
              ),
            ),
          ),
          Text(
            '${percent.toInt()}%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniAudioPlayer extends StatefulWidget {
  final String audioUrl;
  const MiniAudioPlayer({super.key, required this.audioUrl});

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      debugPrint('Lỗi phát âm thanh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: AppColors.primary,
              size: 34,
            ),
            onPressed: _togglePlay,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.primaryLighter,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(_position),
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
