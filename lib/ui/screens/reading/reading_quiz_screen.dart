import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_result_screen.dart';

class QuizQuestion {
  final String prompt;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({required this.prompt, required this.options, required this.correctIndex});
}

class ReadingQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;

  const ReadingQuizScreen({super.key, required this.questions});

  @override
  State<ReadingQuizScreen> createState() => _ReadingQuizScreenState();
}

class _ReadingQuizScreenState extends State<ReadingQuizScreen> {
  late final PageController _pageController;
  late List<int?> _selected; // selected index per question
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _selected = List<int?>.filled(widget.questions.length, null);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int qIndex, int optIndex) {
    if (_selected[qIndex] != null) return; // already answered
    setState(() {
      _selected[qIndex] = optIndex;
      // If all questions answered, navigate to results after brief delay
      if (_selected.every((e) => e != null)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // compute results and pass questions + selections to result screen
        final correct = List.generate(widget.questions.length, (i) => _selected[i] == widget.questions[i].correctIndex ? 1 : 0).reduce((a, b) => a + b);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ReadingResultScreen(
            correct: correct,
            total: widget.questions.length,
            questions: widget.questions,
            selectedIndices: _selected,
          ),
        ));
      });
      }
    });
  }

  Color? _optionColor(int qIndex, int optIndex) {
    final sel = _selected[qIndex];
    if (sel == null) return null;
    final correct = widget.questions[qIndex].correctIndex;
    if (optIndex == correct) return AppColors.answerCorrect;
    if (optIndex == sel && sel != correct) return AppColors.answerWrong;
    return null;
  }

  Border? _optionBorder(int qIndex, int optIndex) {
    final sel = _selected[qIndex];
    final correct = widget.questions[qIndex].correctIndex;
    if (sel == null) return Border.all(color: AppColors.answerBorderDefault);
    if (optIndex == correct) return Border.all(color: AppColors.answerBorderCorrect, width: 2);
    if (optIndex == sel && sel != correct) return Border.all(color: AppColors.answerBorderWrong, width: 2);
    return Border.all(color: AppColors.answerBorderDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Câu ${_currentPage + 1}',
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  'Giải thích',
                  style: TextStyle(color: AppColors.appBarFg, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.questions.length,
        onPageChanged: (p) => setState(() => _currentPage = p),
        itemBuilder: (context, index) {
          final q = widget.questions[index];
          return Column(
            children: [
              // 1. TOP AREA: Câu hỏi & Các khung đáp án hiển thị (Có thể cuộn được)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Khung chứa câu hỏi
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter, // Màu nền cam nhạt theo ảnh
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          q.prompt,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4),
                        ),
                      ),
                      
                      const SizedBox(height: 28), // Khoảng cách cố định giữa câu hỏi và list đáp án

                      // Khung hiển thị các đáp án
                      ...List.generate(q.options.length, (oi) {
                        final bg = _optionColor(index, oi);
                        final border = _optionBorder(index, oi);
                        final label = String.fromCharCode(65 + oi);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: bg ?? Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: border,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: border,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    q.options[oi],
                                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // 2. BOTTOM AREA: Hàng hiển thị "Câu 1" và các nút bấm A B C D được ghim cố định
              SafeArea(
                top: false, // Chỉ lấy lề đáy an toàn
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  color: AppColors.background, // Để khi cuộn chữ không lấn vào vùng này
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text Câu thứ mấy
                      Text(
                        'Câu ${index + 1}',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      
                      // Cụm Nút bấm A, B, C, D
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(q.options.length, (i) {
                          final bg = _optionColor(index, i);
                          final border = _optionBorder(index, i);
                          
                          return Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: GestureDetector(
                              onTap: () => _select(index, i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44, // Kích cỡ vừa phải giống trong hình
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: border,
                                  color: bg ?? Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + i),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: bg != null ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}