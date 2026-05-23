import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';

import '../../../data/models/speaking_part_info.dart';
import '../../../data/models/speaking_question.dart';
import '../../../data/models/speaking_evaluation_model.dart';
import '../../../providers/speaking_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../widgets/speaking/speaking_explanation_panel.dart';

enum _Phase { prepare, recording, evaluating, done }

class SpeakingDoingScreen extends StatefulWidget {
  final SpeakingPartInfo part;
  final int questionCount;
  final bool examMode;

  const SpeakingDoingScreen({
    super.key,
    required this.part,
    this.questionCount = 5,
    this.examMode = false,
  });

  @override
  State<SpeakingDoingScreen> createState() => _SpeakingDoingScreenState();
}

class _SpeakingDoingScreenState extends State<SpeakingDoingScreen>
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

  bool _showPanel = false;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(_progressCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final practiceMode = !widget.examMode;
      context
          .read<SpeakingProvider>()
          .fetchQuestionsByPart(
            widget.part.partNumber,
            practiceMode: practiceMode,
          )
          .then((_) {
        if (mounted) {
          setState(() {
            final all = context.read<SpeakingProvider>().getQuestionsForPart(
                  widget.part.partNumber,
                  practiceMode: practiceMode,
                );
            _tasks = all.take(widget.questionCount).toList();
            _isInitialized = true;

            if (_tasks.isNotEmpty) {
              _updateProgress();
              _phase = _Phase.prepare;
            }
          });
        }
      });
    });
  }

  void _updateProgress() {
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

  @override
  void dispose() {
    _timer?.cancel();
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
            '${directory.path}/speaking_temp_${DateTime.now().millisecondsSinceEpoch}.m4a';
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

    final evaluation = await context.read<SpeakingProvider>().evaluateAnswer(
          _currentTask!.id,
          _lastRecordingPath!,
          subQuestionIndex: _currentTask!.questions.isNotEmpty
              ? _currentSubQuestionIndex
              : null,
        );

    if (evaluation != null) {
      _showEvaluationResult(evaluation);
    } else {
      _moveToNext();
    }
  }

  void _moveToNext() {
    TtsService().stop();
    if (_currentTask != null &&
        _currentTask!.questions.isNotEmpty &&
        _currentSubQuestionIndex < _currentTask!.questions.length - 1) {
      setState(() {
        _currentSubQuestionIndex++;
        _phase = _Phase.prepare;
      });
      _updateProgress();
    } else {
      if (_currentTaskIndex < _tasks.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() => _phase = _Phase.done);
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
              Expanded(child: _buildPageViewBody()),
              _buildBottomArea(),
            ],
          ),
          if (_phase == _Phase.evaluating) _buildEvaluatingOverlay(),
          _buildExplanationPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final title = _tasks.isNotEmpty
        ? 'Câu ${_currentTaskIndex + 1}/${_tasks.length}'
        : widget.part.titleVi;
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
          onPressed: () {},
          icon: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 20),
        ),
        IconButton(
          onPressed: () => _showSettingsDialog(),
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
        ),
        TextButton(
          onPressed: () => setState(() => _showPanel = !_showPanel),
          style: TextButton.styleFrom(padding: const EdgeInsets.only(right: 12)),
          child: const Text('Giải thích',
              style: TextStyle(
                  color: Colors.white, 
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
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
      physics: const BouncingScrollPhysics(),
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
          _phase = _Phase.prepare;
          _showPanel = false;
        });
        _updateProgress();
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
          // Gộp Card tiêu đề và Hình ảnh vào 1 Container duy nhất
          _buildPromptAndImage(task),
          
          const SizedBox(height: 20),
          if (task.questions.isNotEmpty)
            _buildCurrentQuestionCard(task)
          else if (widget.part.partNumber == 3 || widget.part.partNumber == 4)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('⚠️ Không tìm thấy dữ liệu câu hỏi.'))),
          const SizedBox(height: 24),
          if (_phase == _Phase.recording) _buildCountdownChip(),
        ],
      ),
    );
  }

  Widget _buildPromptAndImage(SpeakingQuestion task) {
    final String promptText = task.text.trim();
    final bool hasImage = task.imageUrl != null && task.imageUrl!.isNotEmpty;
    final bool isPart1 = widget.part.partNumber == 1;

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
          // Phần Text Hướng dẫn
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getPromptLabel(widget.part.partNumber), 
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
          // Phần Hình ảnh (nằm ngay dưới text, không khoảng trống)
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text('Câu hỏi ${_currentSubQuestionIndex + 1} / ${task.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 16),
          Text(task.questions[_currentSubQuestionIndex], textAlign: TextAlign.center, style: TextStyle(fontSize: 18 * _fontSizeFactor, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCountdownChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
        child: Text('Ghi âm: ${_secondsLeft}s', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.orange)),
      ),
    );
  }

  Widget _buildBottomArea() {
    if (_phase == _Phase.evaluating || _phase == _Phase.done) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _phase == _Phase.prepare
            ? ElevatedButton(
                onPressed: _startRecording,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
                child: const Text('Bắt đầu trả lời', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            : Column(
                children: [
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: FloatingActionButton(onPressed: _skip, backgroundColor: Colors.orange, child: const Icon(Icons.mic_rounded, size: 36, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(onPressed: _skip, child: const Text('Bỏ qua / Kết thúc câu này')),
                ],
              ),
      ),
    );
  }

  Widget _buildEvaluatingOverlay() {
    return Container(
      color: Colors.black87,
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildExplanationPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SpeakingExplanationPanel(
        isVisible: _showPanel,
        question: _currentTask,
        partNumber: widget.part.partNumber,
        onClose: () => setState(() => _showPanel = false),
      ),
    );
  }

  void _showEvaluationResult(SpeakingEvaluation result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Điểm: ${result.overallScore.toStringAsFixed(1)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: Text(result.feedback, style: const TextStyle(fontSize: 15, height: 1.6)))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); _moveToNext(); },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Tiếp tục', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('🎉 Hoàn thành!'), content: const Text('Bạn đã hoàn thành phần thi này.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))]));
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
