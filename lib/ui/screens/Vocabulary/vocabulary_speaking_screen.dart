import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../../core/services/tts_service.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../shared/practice_dialogs.dart';

class VocabularySpeakingScreen extends StatefulWidget {
  final List<VocabularyModel> words;
  final int initialIndex;

  const VocabularySpeakingScreen({
    super.key,
    required this.words,
    this.initialIndex = 0,
  });

  @override
  State<VocabularySpeakingScreen> createState() => _VocabularySpeakingScreenState();
}

class _VocabularySpeakingScreenState extends State<VocabularySpeakingScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  
  // Real Speech to Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _recognizedText = '';
  
  // State variables
  bool _hasRecorded = false;
  bool _isAnalyzing = false;
  bool _showResult = false;
  
  // EP & Scoring
  int _accuracyScore = 0;
  String _pronunciationFeedback = '';
  List<Map<String, dynamic>> _phonemes = [];
  int _epAwarded = 0;
  bool _epLoading = false;
  bool _epShownForCurrentWord = false;

  // Animations
  late AnimationController _pulseController;
  final List<double> _waveAmplitudes = List.generate(8, (_) => 0.0);
  Timer? _recordingTimer;
  Timer? _waveTimer;
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Setup animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recordingTimer?.cancel();
    _waveTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  VocabularyModel get _currentWord => widget.words[_currentIndex];

  // ── Speech-to-Text Initialization ──────────────────────────────────────────
  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'notListening' || status == 'done') {
            if (_isListening) {
              _stopListening();
            }
          }
        },
        onError: (errorNotification) {
          debugPrint('STT Error: ${errorNotification.errorMsg}');
          if (_isListening) {
            _stopListening();
          }
        },
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Speech init error: $e');
    }
  }

  // ── Listening Control ──────────────────────────────────────────────────────
  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
    }

    if (_speechEnabled) {
      setState(() {
        _isListening = true;
        _hasRecorded = false;
        _showResult = false;
        _recognizedText = '';
        _recordingDuration = 0;
      });

      // Start timer (timeout after 10s if user doesn't say anything)
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration++;
            if (_recordingDuration >= 10) {
              _stopListening();
            }
          });
        }
      });

      // Generate wave animation values
      _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted) {
          setState(() {
            for (int i = 0; i < _waveAmplitudes.length; i++) {
              _waveAmplitudes[i] = Random().nextDouble() * 40 + 10;
            }
          });
        }
      });

      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          }
        },
        localeId: 'en_US', // English practicing
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 4),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kích hoạt Micro. Hãy cấp quyền truy cập mic cho trình duyệt/thiết bị của bạn.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      _recordingTimer?.cancel();
      _waveTimer?.cancel();
      
      setState(() {
        _isListening = false;
        _hasRecorded = true;
      });
    } catch (e) {
      debugPrint('Error stopping STT: $e');
    }
  }

  // ── Similarity Calculation (Real string comparison) ────────────────────────
  double _calculateSimilarity(String original, String spoken) {
    original = original.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    spoken = spoken.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');

    if (original.isEmpty || spoken.isEmpty) return 0.0;
    if (original == spoken) return 1.0;

    // Direct subset matching
    if (spoken.contains(original) || original.contains(spoken)) {
      int commonLen = min(original.length, spoken.length);
      int maxLen = max(original.length, spoken.length);
      return (commonLen / maxLen) * 0.95;
    }

    // Levenshtein distance
    int distance = _levenshtein(original, spoken);
    int maxLen = max(original.length, spoken.length);
    return (1.0 - (distance / maxLen)).clamp(0.0, 1.0);
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v0[t.length];
  }

  // ── AI Evaluation Logic (REAL STT Matching) ───────────────────────────────
  Future<void> _analyzePronunciation() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Short processing delay for better UX
    await Future.delayed(const Duration(milliseconds: 1000));

    // Calculate real score!
    double similarity = _calculateSimilarity(_currentWord.word, _recognizedText);
    int score = (similarity * 100).round();

    // Heuristics for feedback and phonemes mapping
    List<Map<String, dynamic>> breakdown = [];
    final word = _currentWord.word.toLowerCase();
    final spoken = _recognizedText.toLowerCase();
    
    if (score == 0) {
      if (word.length > 5) {
        int mid = word.length ~/ 2;
        breakdown.add({'syllable': word.substring(0, mid), 'correct': false});
        breakdown.add({'syllable': word.substring(mid), 'correct': false});
      } else {
        breakdown.add({'syllable': word, 'correct': false});
      }
    } else {
      // Dynamic syllable matching based on actual spoken text!
      if (word.length > 5) {
        int mid = word.length ~/ 2;
        String s1 = word.substring(0, mid);
        String s2 = word.substring(mid);

        // Check if the spoken text contains s1 or s2, or is very similar
        bool s1Matched = spoken.contains(s1) || _calculateSimilarity(s1, spoken) > 0.55;
        bool s2Matched = spoken.contains(s2) || _calculateSimilarity(s2, spoken) > 0.55;

        // Force both correct if overall score is high (reward fluent pronunciation)
        if (score >= 85) {
          s1Matched = true;
          s2Matched = true;
        }

        breakdown.add({'syllable': s1, 'correct': s1Matched});
        breakdown.add({'syllable': s2, 'correct': s2Matched});
      } else {
        breakdown.add({'syllable': word, 'correct': score >= 80});
      }
    }

    String feedback = 'Phát âm tuyệt vời! Bạn đã phát âm chuẩn xác từ mục tiêu.';
    if (score == 0) {
      feedback = 'Hệ thống chưa nghe thấy giọng của bạn. Vui lòng nhấn micro và thử nói to hơn.';
    } else if (score >= 50 && score < 80) {
      // Check if they said a completely different word
      // (For example, s1 and s2 both didn't match, or Levenshtein distance is low)
      bool majorDifference = false;
      if (word.length > 5) {
        int mid = word.length ~/ 2;
        String s1 = word.substring(0, mid);
        bool s1Matched = spoken.contains(s1) || _calculateSimilarity(s1, spoken) > 0.55;
        if (!s1Matched && !spoken.contains(word)) {
          majorDifference = true;
        }
      }
      
      if (majorDifference) {
        score = (score * 0.6).round(); // Downgrade score since they spoke a completely different word
        feedback = 'Có vẻ bạn đã phát âm nhầm sang một từ khác (AI nghe thành: "$_recognizedText"). Hãy nghe lại phát âm mẫu và thử lại.';
      } else {
        feedback = 'Phát âm khá tốt nhưng chưa hoàn toàn chuẩn xác. Chú ý bật hơi nhẹ và phát âm rõ âm đuôi.';
      }
    } else if (score < 50) {
      feedback = 'Phát âm chưa chính xác (AI nghe thành: "$_recognizedText"). Bạn hãy nhấn nút Loa để nghe lại phát âm chuẩn và luyện tập thêm.';
    }

    setState(() {
      _isAnalyzing = false;
      _showResult = true;
      _accuracyScore = score;
      _pronunciationFeedback = feedback;
      _phonemes = breakdown;
    });

    // Award EP if score >= 80%
    if (!_epShownForCurrentWord && score >= 80) {
      _epShownForCurrentWord = true;
      setState(() => _epLoading = true);
      
      final ep = await context.read<UserProvider>().recordActivity(
        activityType: 'VocabSpeaking',
        referenceId: '${_currentWord.id}_speaking',
      );

      if (mounted) {
        setState(() {
          _epAwarded = ep?.epAwarded ?? 0;
          _epLoading = false;
        });
      }
    }
  }

  void _handleNextWord() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _hasRecorded = false;
        _showResult = false;
        _epAwarded = 0;
        _epLoading = false;
        _epShownForCurrentWord = false;
        _recognizedText = '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Chúc mừng! Bạn đã hoàn thành luyện nói tất cả từ vựng!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / widget.words.length;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final exit = await showExitPracticeDialog(
          context,
          text: 'Tiến trình luyện nói từ vựng của bạn chưa hoàn thành. Bạn có chắc muốn thoát?',
        );
        if (exit && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Luyện nói từ vựng',
          centerTitle: true,
          onBack: () => Navigator.maybePop(context),
        ),
        body: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
            minHeight: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Từ số ${_currentIndex + 1}/${widget.words.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                Text(
                  _currentWord.wordType,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Word card showing spelling & meaning ───────────────────
                  _buildWordCard(),

                  const SizedBox(height: 30),

                  // ── Microphone / Wave / Real-time speech display Area ──────
                  if (!_showResult && !_isAnalyzing) _buildRecordingInterface(),

                  // ── AI Loading Indicator ──────────────────────────────────
                  if (_isAnalyzing) _buildAnalyzingState(),

                  // ── Result Section ────────────────────────────────────────
                  if (_showResult) _buildResultSection(),
                ],
              ),
            ),
          ),

          // ── Bottom Buttons ────────────────────────────────────────────────
          _buildBottomActionButtons(),
        ],
      ),
    ),
  );
}

  Widget _buildWordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentWord.wordType.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currentWord.word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentWord.phonetic,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  TtsService().speak(_currentWord.word);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Boxicons.bx_volume_full,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30, height: 1),
          const SizedBox(height: 16),
          Text(
            _currentWord.definitionVi,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingInterface() {
    return Column(
      children: [
        if (_isListening) ...[
          const Text(
            'Hệ thống đang lắng nghe...',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '00:${_recordingDuration.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Waveforms
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _waveAmplitudes.map((amp) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 6,
                  height: amp,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          
          // Live recognized words
          if (_recognizedText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Text('Từ đã nghe thấy:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '"$_recognizedText"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ] else if (_hasRecorded) ...[
          const Text(
            'Đã ghi nhận giọng nói của bạn',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Bạn đã phát âm:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  _recognizedText.isEmpty ? '"(Không có âm thanh)"' : '"$_recognizedText"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _recognizedText.isEmpty ? Colors.red : AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const Text(
            'Nhấn nút Microphone để phát âm',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
        
        const SizedBox(height: 40),

        // Record Button
        GestureDetector(
          onTap: () {
            if (_isListening) {
              _stopListening();
            } else {
              _startListening();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isListening)
                ...List.generate(2, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 90 + (_pulseController.value * 40 * (index + 1)),
                        height: 90 + (_pulseController.value * 40 * (index + 1)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.15 / (index + 1)),
                        ),
                      );
                    },
                  );
                }),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isListening
                      ? const LinearGradient(colors: [Colors.red, Colors.orange])
                      : AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : AppColors.primary).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Boxicons.bx_stop : Boxicons.bx_microphone,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'AI đang so khớp phát âm...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đang so khớp các âm tiết với bản xứ...',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildResultSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Column(
        children: [
          // Circular Score Gauge
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _accuracyScore / 100,
                    strokeWidth: 10,
                    color: _accuracyScore >= 80 ? AppColors.success : (_accuracyScore >= 40 ? Colors.orange : Colors.red),
                    backgroundColor: AppColors.divider,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_accuracyScore%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _accuracyScore >= 80 ? AppColors.success : (_accuracyScore >= 40 ? Colors.orange : Colors.red),
                      ),
                    ),
                    const Text(
                      'Độ chính xác',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Real results showing what was spoken
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const Text(
                  'Từ nhận diện:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _recognizedText.isEmpty ? '"(Không nghe thấy giọng nói)"' : '"$_recognizedText"',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _recognizedText.isEmpty ? Colors.red : AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Phonemes details
          if (_recognizedText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Text(
                    'Chi tiết phát âm từng âm tiết:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _phonemes.map((ph) {
                      final isCorrect = ph['correct'] as bool;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCorrect ? AppColors.success.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrect ? AppColors.success.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          ph['syllable'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? AppColors.success : Colors.orange.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Feedback message
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _accuracyScore >= 80 ? Colors.green.shade50 : (_accuracyScore >= 40 ? Colors.orange.shade50 : Colors.red.shade50),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accuracyScore >= 80 ? Colors.green.shade100 : (_accuracyScore >= 40 ? Colors.orange.shade100 : Colors.red.shade100),
              ),
            ),
            child: Text(
              _pronunciationFeedback,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _accuracyScore >= 80 ? Colors.green.shade800 : (_accuracyScore >= 40 ? Colors.orange.shade800 : Colors.red.shade800),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // EP Reward Badge
          _buildEpBadge(),
        ],
      ),
    );
  }

  Widget _buildEpBadge() {
    if (_epLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            SizedBox(width: 8),
            Text('Đang tính EP...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    if (_epAwarded <= 0) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              '+$_epAwarded EP',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_hasRecorded && !_showResult && !_isAnalyzing) ...[
            // Record again
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _hasRecorded = false;
                  _recognizedText = '';
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Icon(Boxicons.bx_redo, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            // Analyze button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _analyzePronunciation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Boxicons.bxs_magic_wand),
                label: const Text(
                  'AI Đánh giá phát âm',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ] else if (_showResult) ...[
            // Re-practice
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _showResult = false;
                  _hasRecorded = false;
                  _recognizedText = '';
                  _epAwarded = 0;
                  _epShownForCurrentWord = false;
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Icon(Boxicons.bx_redo, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            // Next Word button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleNextWord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Boxicons.bx_right_arrow_alt),
                label: Text(
                  _currentIndex < widget.words.length - 1 ? 'Từ tiếp theo' : 'Hoàn thành',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ] else ...[
            // Default placeholder or just an empty container
            Expanded(
              child: Text(
                _isListening ? 'Hãy phát âm từ vựng to và rõ ràng...' : 'Hãy bắt đầu bằng cách ghi âm giọng nói của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
