import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/grammar_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/grammar_model.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/listening_question.dart';

class GrammarExerciseScreen extends StatefulWidget {
  final GrammarTopic topic;
  const GrammarExerciseScreen({super.key, required this.topic});

  @override
  State<GrammarExerciseScreen> createState() => _GrammarExerciseScreenState();
}

class _GrammarExerciseScreenState extends State<GrammarExerciseScreen> {
  int _currentIndex = 0;
  final Map<int, String?> _selectedOptions = {};
  final Map<int, bool> _isAnsweredMap = {};
  int _correctCount = 0;
  bool _submittingScore = false;
  late final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<GrammarProvider>().fetchExercises(widget.topic.id);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkAnswer(ListeningQuestion currentQuestion) {
    final selectedOpt = _selectedOptions[_currentIndex];
    if (selectedOpt == null || (_isAnsweredMap[_currentIndex] ?? false)) return;

    final isCorrect = selectedOpt == currentQuestion.correctAnswer;
    setState(() {
      _isAnsweredMap[_currentIndex] = true;
      if (isCorrect) {
        _correctCount++;
      }
    });
  }

  Future<void> _nextQuestion(List<ListeningQuestion> exercises) async {
    if (_currentIndex < exercises.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Recalculate correctCount based on all questions to be absolutely certain of final state accuracy
      int correct = 0;
      for (int i = 0; i < exercises.length; i++) {
        if (_isAnsweredMap[i] == true && _selectedOptions[i] == exercises[i].correctAnswer) {
          correct++;
        }
      }
      _correctCount = correct;
      await _submitResults();
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitResults() async {
    setState(() => _submittingScore = true);
    try {
      debugPrint('⚡ [GrammarExerciseScreen] Submitting score: $_correctCount/${_currentIndex + 1} for ${widget.topic.id}');
      final result = await context.read<UserProvider>().recordActivity(
        activityType: 'GrammarExercise',
        referenceId: widget.topic.id,
        correctAnswers: _correctCount,
        totalAnswers: _currentIndex + 1,
      );

      _showResultDialog(result?.epAwarded ?? (_correctCount * 2));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _submittingScore = false);
    }
  }

  void _showResultDialog(int epAwarded) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final percent = (_correctCount / (_currentIndex + 1) * 100).round();
        String title;
        String desc;
        IconData icon;
        Color color;

        if (percent >= 80) {
          title = 'Xuất Sắc! 🏆';
          desc = 'Bạn đã nắm vững điểm ngữ pháp này!';
          icon = Boxicons.bxs_trophy;
          color = AppColors.primary;
        } else if (percent >= 50) {
          title = 'Khá Tốt! 👍';
          desc = 'Hãy ôn tập thêm để đạt điểm tuyệt đối nhé.';
          icon = Boxicons.bxs_like;
          color = AppColors.blue;
        } else {
          title = 'Cố Gắng Lên! 💪';
          desc = 'Đọc lại lý thuyết và thực hành lại để tiến bộ nhé.';
          icon = Boxicons.bx_revision;
          color = AppColors.purple;
        }

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, size: 44, color: color),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                // Score statistics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatBox('Đúng', '$_correctCount/${_currentIndex + 1}', AppColors.success),
                    _buildStatBox('Tỷ lệ', '$percent%', AppColors.blue),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Boxicons.bxs_star, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '+$epAwarded EP Thưởng 🔥',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(this.context); // Return to Hub
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Hoàn thành',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final exit = await showExitPracticeDialog(
          context,
          text: 'Tiến trình làm bài tập ngữ pháp của bạn chưa hoàn thành. Bạn có chắc muốn thoát?',
        );
        if (exit && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Luyện Tập Ngữ Pháp',
          onBack: () => Navigator.maybePop(context),
        ),
      body: Consumer<GrammarProvider>(
        builder: (context, grammarProvider, child) {
          if (grammarProvider.isLoadingExercises) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (grammarProvider.exercisesError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Boxicons.bx_error, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải danh sách bài tập',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      grammarProvider.exercisesError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => grammarProvider.fetchExercises(widget.topic.id),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final exercises = grammarProvider.exercises;
          if (exercises.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Boxicons.bx_file_blank, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Hiện chưa có câu hỏi luyện tập cho chủ đề này.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Trở lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final question = exercises[_currentIndex];

          return Column(
            children: [
              // Progress Bar Header
              _buildProgressHeader(exercises.length),

              // Question body and options
              // Question body and options using PageView.builder to support hand swiping
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: exercises.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final q = exercises[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Part badge and difficulty
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'TOEIC Part 5',
                                  style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  q.difficulty == 'easy' 
                                      ? 'Dễ' 
                                      : q.difficulty == 'medium' ? 'Trung bình' : 'Khó',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Question Text
                          Text(
                            q.questionText ?? '',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4 options cards
                          ...['A', 'B', 'C', 'D'].map((opt) {
                            final optText = q.options.firstWhere(
                              (element) => element.trim().startsWith(opt),
                              orElse: () => '',
                            );

                            if (optText.isEmpty) return const SizedBox.shrink();

                            return _buildOptionCard(opt, optText, q);
                          }),

                          // Dynamic explanation display immediately when checked
                          if (_isAnsweredMap[index] ?? false) _buildExplanationSection(q),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom sticky control panel
              _buildBottomControlPanel(exercises),
            ],
          );
        },
      ),
    ),
  );
}

  Widget _buildProgressHeader(int totalCount) {
    final progress = (_currentIndex + 1) / totalCount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu hỏi ${_currentIndex + 1} / $totalCount',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              Row(
                children: [
                  const Icon(Boxicons.bx_check, color: AppColors.success, size: 18),
                  const SizedBox(width: 2),
                  Text(
                    'Đúng: $_correctCount',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryLighter,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String code, String text, ListeningQuestion question) {
    final currentSelected = _selectedOptions[_currentIndex];
    final currentIsAnswered = _isAnsweredMap[_currentIndex] ?? false;
    final isSelected = currentSelected == code;
    final isCorrect = code == question.correctAnswer;

    Color cardBg = AppColors.surface;
    Color borderCol = AppColors.answerBorderDefault;
    Color textCol = AppColors.textPrimary;
    Widget? stateIcon;

    if (currentIsAnswered) {
      if (isCorrect) {
        // Đúng màu xanh lá
        cardBg = AppColors.answerCorrect;
        borderCol = AppColors.answerBorderCorrect;
        textCol = AppColors.answerBorderCorrect;
        stateIcon = const Icon(Icons.check_circle_rounded, color: AppColors.answerBorderCorrect, size: 20);
      } else if (isSelected) {
        // Chọn sai màu đỏ
        cardBg = AppColors.answerWrong;
        borderCol = AppColors.answerBorderWrong;
        textCol = AppColors.answerBorderWrong;
        stateIcon = const Icon(Icons.cancel_rounded, color: AppColors.answerBorderWrong, size: 20);
      }
    } else {
      if (isSelected) {
        // Đang chọn (chưa check) màu cam nhạt
        cardBg = AppColors.answerSelected;
        borderCol = AppColors.answerBorderSelected;
        textCol = AppColors.primaryDark;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: currentIsAnswered
              ? null
              : () {
                  setState(() {
                    _selectedOptions[_currentIndex] = code;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Circular Option index
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: textCol,
                    ),
                  ),
                ),
                if (stateIcon != null) ...[
                  const SizedBox(width: 8),
                  stateIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationSection(ListeningQuestion question) {
    final currentSelected = _selectedOptions[_currentIndex];
    final isCorrect = currentSelected == question.correctAnswer;
    
    // Parse dynamic custom explanation DTO map safely
    String translation = '';
    Map<String, dynamic> optExplanations = {};
    String grammarExplanation = '';

    if (question.explanation is Map) {
      final expMap = question.explanation as Map;
      translation = expMap['translation'] ?? '';
      optExplanations = Map<String, dynamic>.from(expMap['option_explanations'] ?? {});
      grammarExplanation = expMap['grammar_explanation'] ?? '';
    } else if (question.explanation is String) {
      grammarExplanation = question.explanation as String;
    }

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Boxicons.bxs_check_circle : Boxicons.bxs_info_circle,
                color: isCorrect ? AppColors.success : AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Đáp Án Chính Xác!' : 'Đáp Án Chưa Đúng!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Translation
          if (translation.isNotEmpty) ...[
            const Text(
              'Dịch Nghĩa:',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              translation,
              style: const TextStyle(fontSize: 13, color: AppColors.textMid, fontStyle: FontStyle.italic, height: 1.4),
            ),
            const SizedBox(height: 14),
          ],

          // Option Explanations
          if (optExplanations.isNotEmpty) ...[
            const Text(
              'Giải Thích Phương Án:',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            ...optExplanations.entries.map((entry) {
              final isCorrectOpt = entry.key == question.correctAnswer;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}. ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: isCorrectOpt ? AppColors.success : AppColors.textPrimary,
                        fontSize: 12.5
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: isCorrectOpt ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),
          ],

          // Grammar Explanation
          if (grammarExplanation.isNotEmpty) ...[
            const Text(
              'Giải Thích Ngữ Pháp:',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              grammarExplanation,
              style: const TextStyle(fontSize: 13, color: AppColors.textMid, height: 1.45),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControlPanel(List<ListeningQuestion> exercises) {
    final question = exercises[_currentIndex];
    final isLast = _currentIndex == exercises.length - 1;
    final currentSelected = _selectedOptions[_currentIndex];
    final currentIsAnswered = _isAnsweredMap[_currentIndex] ?? false;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous Button
            if (_currentIndex > 0) ...[
              OutlinedButton.icon(
                onPressed: _prevQuestion,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Trước'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // Primary Action Button (Check or Next/Complete)
            Expanded(
              child: SizedBox(
                height: 52,
                child: currentIsAnswered
                    ? ElevatedButton(
                        onPressed: _submittingScore ? null : () => _nextQuestion(exercises),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 1,
                        ),
                        child: _submittingScore
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLast ? 'Hoàn Thành Bài Tập' : 'Tiếp Tục',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      )
                    : ElevatedButton(
                        onPressed: currentSelected == null ? null : () => _checkAnswer(question),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentSelected == null ? Colors.grey.shade300 : AppColors.primary,
                          foregroundColor: currentSelected == null ? Colors.grey.shade500 : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Kiểm Tra',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
