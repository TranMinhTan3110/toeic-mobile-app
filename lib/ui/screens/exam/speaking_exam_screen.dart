import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

import '../../../data/models/speaking_question.dart';
import '../../../data/models/speaking_evaluation_model.dart';
import '../../../providers/speaking_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../shared/practice_dialogs.dart';

enum _Phase { prepare, recording, evaluating, done }

class SpeakingExamScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const SpeakingExamScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<SpeakingExamScreen> createState() => _SpeakingExamScreenState();
}

class _SpeakingExamScreenState extends State<SpeakingExamScreen>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final PageController _pageController = PageController();
  String? _lastRecordingPath;

  List<SpeakingQuestion> _tasks = [];
  int _currentTaskIndex = 0;
  int _currentSubQuestionIndex = 0;
  bool _isInitialized = false;

  double _ttsRate = 0.5;
  double _fontSizeFactor = 1.0;

  SpeakingQuestion? get _currentTask =>
      (_tasks.isNotEmpty && _currentTaskIndex < _tasks.length)
          ? _tasks[_currentTaskIndex]
          : null;

  _Phase _phase = _Phase.prepare;
  int _secondsLeft = 0;
  Timer? _timer;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  // Tổng thời gian ước tính trôi qua (giúp hiển thị đồng hồ chạy chung của đề thi)
  int _elapsedSeconds = 0;
  Timer? _overallTimer;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(_progressCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpeakingProvider>().fetchExamQuestions(widget.examId).then((_) {
        if (mounted) {
          setState(() {
            _tasks = context.read<SpeakingProvider>().examQuestions;
            _isInitialized = true;

            if (_tasks.isNotEmpty) {
              _updateProgress();
              _startPrepare();
              _startOverallTimer();
            }
          });
        }
      });
    });
  }

  void _startOverallTimer() {
    _overallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  String _formatElapsedTime(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _updateProgress() {
    if (_tasks.isEmpty) return;
    double progress = (_currentTaskIndex) / _tasks.length;
    if (_currentTask != null && _currentTask!.questions.isNotEmpty) {
      progress +=
          ((_currentSubQuestionIndex + 1) / _currentTask!.questions.length) /
              _tasks.length;
    } else {
      progress += (1.0 / _tasks.length);
    }

    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: progress,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward(from: 0);
  }

  void _startPrepare() {
    if (_currentTask == null) return;
    setState(() {
      _phase = _Phase.prepare;
      _secondsLeft = _currentTask!.prepSeconds;
    });
    if (_secondsLeft <= 0) {
      _startRecording();
    } else {
      _startCountdown(() => _startRecording());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _overallTimer?.cancel();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    _audioRecorder.dispose();
    _pageController.dispose();
    TtsService().stop();
    super.dispose();
  }

  Future<void> _startRecordingLogic() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/speaking_exam_${widget.examId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
        const config = RecordConfig();
        await _audioRecorder.start(config, path: path);
        _lastRecordingPath = path;
      }
    } catch (e) {
      debugPrint('Lỗi mic: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_currentTask == null) return;

    await _startRecordingLogic();
    _pulseCtrl.repeat(reverse: true);

    if (!mounted) return;
    setState(() {
      _phase = _Phase.recording;
      if (_currentTask!.questions.isNotEmpty) {
        _secondsLeft = _currentTask!.answerTimes[_currentSubQuestionIndex];
      } else {
        _secondsLeft = _currentTask!.recordSeconds;
      }
    });
    _startCountdown(_onRecordingTimeUp);
  }

  void _onRecordingTimeUp() async {
    final path = await _audioRecorder.stop();
    if (path != null) _lastRecordingPath = path;
    _pulseCtrl.stop();
    _evaluateAndNext();
  }

  Future<void> _evaluateAndNext() async {
    if (_lastRecordingPath == null || _currentTask == null) {
      _moveToNext();
      return;
    }

    setState(() => _phase = _Phase.evaluating);

    // Gửi bài lên chấm điểm (trong lúc thi, ta vẫn chấm điểm và lưu kết quả)
    final evaluation = await context.read<SpeakingProvider>().evaluateAnswer(
          _currentTask!.id,
          _lastRecordingPath!,
          subQuestionIndex: _currentTask!.questions.isNotEmpty
              ? _currentSubQuestionIndex
              : null,
        );

    // Không hiển thị kết quả chấm điểm ngay lúc làm bài thi
    _moveToNext();
  }

  void _moveToNext() {
    TtsService().stop();
    if (_currentTask != null &&
        _currentTask!.questions.isNotEmpty &&
        _currentSubQuestionIndex < _currentTask!.questions.length - 1) {
      setState(() {
        _currentSubQuestionIndex++;
      });
      _updateProgress();
      _startPrepare();
    } else {
      if (_currentTaskIndex < _tasks.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() => _phase = _Phase.done);
        _overallTimer?.cancel();
        _showCompletionDialog();
      }
    }
  }

  void _startCountdown(VoidCallback onDone) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        onDone();
      }
    });
  }

  void _skip() {
    if (_phase == _Phase.recording) {
      _timer?.cancel();
      _onRecordingTimeUp();
    } else {
      _moveToNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeakingProvider>();

    if (provider.isLoading || !_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopProgressBar(),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: (details) {
                    // Cho phép vuốt ngang qua câu khác như yêu cầu của người dùng
                    if (details.primaryVelocity! > 300) {
                      // Vuốt sang trái (quay lại câu trước)
                      if (_currentTaskIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    } else if (details.primaryVelocity! < -300) {
                      // Vuốt sang phải (sang câu tiếp theo)
                      _skip();
                    }
                  },
                  child: _buildPageViewBody(),
                ),
              ),
              _buildBottomArea(),
            ],
          ),
          if (_phase == _Phase.evaluating) _buildEvaluatingOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final title = _tasks.isNotEmpty
        ? 'Câu ${_currentTaskIndex + 1}/${_tasks.length}'
        : 'TOEIC Speaking Exam';
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => showReportDialog(context),
          icon: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 20),
          tooltip: 'Báo lỗi',
        ),
        IconButton(
          onPressed: () => _showSettingsDialog(),
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          tooltip: 'Cài đặt',
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.redAccent : Colors.white,
            size: 20,
          ),
          tooltip: 'Yêu thích',
        ),
        // Hiển thị đồng hồ đếm giờ làm đề thi
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
                _formatElapsedTime(_elapsedSeconds),
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(
        currentTtsRate: _ttsRate,
        currentFontSizeFactor: _fontSizeFactor,
        onSave: (rate, size) {
          setState(() {
            _ttsRate = rate;
            _fontSizeFactor = size;
          });
          TtsService().setRate(rate);
        },
      ),
    );
  }

  Widget _buildTopProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, _) => LinearProgressIndicator(
        value: _progressAnim.value,
        minHeight: 4,
        backgroundColor: AppColors.primaryLighter,
        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
      ),
    );
  }

  Widget _buildPageViewBody() {
    if (_tasks.isEmpty) return const SizedBox.shrink();

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Chỉ cho vuốt qua gesture
      onPageChanged: (index) {
        _timer?.cancel();
        TtsService().stop();
        if (_phase == _Phase.recording) {
          _audioRecorder.stop();
          _pulseCtrl.stop();
        }
        setState(() {
          _currentTaskIndex = index;
          _currentSubQuestionIndex = 0;
        });
        _updateProgress();
        _startPrepare();
      },
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskContent(_tasks[index]);
      },
    );
  }

  Widget _buildTaskContent(SpeakingQuestion task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromptAndImage(task),
          const SizedBox(height: 20),
          if (task.questions.isNotEmpty)
            _buildCurrentQuestionCard(task),
          const SizedBox(height: 24),
          if (_phase == _Phase.recording) _buildCountdownChip(),
        ],
      ),
    );
  }

  Widget _buildPromptAndImage(SpeakingQuestion task) {
    final String promptText = task.text.trim();
    final bool hasImage = task.imageUrl != null && task.imageUrl!.isNotEmpty;
    final bool isPart1 = task.taskNumber == 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getPromptLabel(task.taskNumber), 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    if (promptText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(promptText, style: TextStyle(fontSize: 14 * _fontSizeFactor, height: 1.5, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              if (isPart1 && promptText.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 22),
                    onPressed: () => TtsService().speak(promptText),
                  ),
                ),
            ],
          ),
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: _buildImageOnly(task.imageUrl!),
            ),
        ],
      ),
    );
  }

  Widget _buildImageOnly(String imageUrl) {
    final isAsset = !imageUrl.startsWith('http');
    return Container(
      width: double.infinity,
      height: 220,
      child: isAsset 
          ? Image.asset(imageUrl, fit: BoxFit.cover) 
          : Image.network(imageUrl, fit: BoxFit.cover),
    );
  }

  String _getPromptLabel(int partNumber) {
    switch (partNumber) {
      case 1:
        return 'Đọc văn bản';
      case 2:
        return 'Mô tả tranh';
      case 3:
        return 'Trả lời câu hỏi';
      case 4:
        return 'Trả lời câu hỏi';
      case 5:
        return 'Bày tỏ quan điểm';
      default:
        return 'Ngữ cảnh';
    }
  }

  Widget _buildCurrentQuestionCard(SpeakingQuestion task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.help_center_rounded,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi ${_currentSubQuestionIndex + 1} / ${task.questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.questions[_currentSubQuestionIndex],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18 * _fontSizeFactor,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownChip() {
    final isPrepare = _phase == _Phase.prepare;
    final color = isPrepare ? AppColors.primary : const Color(0xFFD44B0D);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPrepare ? Icons.timer_outlined : Icons.mic_none_rounded,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              '${isPrepare ? 'Chuẩn bị' : 'Ghi âm'}: ${_secondsLeft}s',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomArea() {
    if (_phase == _Phase.evaluating || _phase == _Phase.done) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: _phase == _Phase.prepare
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _timer?.cancel();
                    _startRecording();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu trả lời',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: GestureDetector(
                      onTap: _skip,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent,
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Bỏ qua / Kết thúc câu này',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEvaluatingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Đang gửi câu trả lời ${_currentSubQuestionIndex + 1}...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 Hoàn thành!', style: TextStyle(fontWeight: FontWeight.bold)), 
        content: const Text('Bạn đã hoàn thành phần thi thử TOEIC Speaking. Chúc mừng bạn!'), 
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog
              Navigator.pop(context); // Thoát về màn hình chi tiết đề thi
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Trở về', style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  final double currentTtsRate;
  final double currentFontSizeFactor;
  final Function(double, double) onSave;

  const _SettingsDialog({
    required this.currentTtsRate,
    required this.currentFontSizeFactor,
    required this.onSave,
  });

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late double _tempTtsRate;
  late double _tempFontSize;

  final List<double> _rates = [0.25, 0.375, 0.5, 0.625, 0.75];
  final List<String> _rateLabels = ['0.5x', '0.75x', '1x', '1.25x', '1.5x'];

  final List<double> _fontSizes = [0.8, 1.0, 1.2, 1.4];
  final List<String> _fontSizeLabels = ['Nhỏ', 'Vừa', 'Lớn', 'Rất lớn'];

  @override
  void initState() {
    super.initState();
    _tempTtsRate = widget.currentTtsRate;
    _tempFontSize = widget.currentFontSizeFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.settings, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cài đặt',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Tốc độ phát âm thanh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_rates.length, (index) {
                final isSelected = _tempTtsRate == _rates[index];
                return GestureDetector(
                  onTap: () => setState(() => _tempTtsRate = _rates[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _rateLabels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kích thước chữ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_fontSizes.length, (index) {
                final isSelected = _tempFontSize == _fontSizes[index];
                return GestureDetector(
                  onTap: () => setState(() => _tempFontSize = _fontSizes[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _fontSizeLabels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_tempTtsRate, _tempFontSize);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
