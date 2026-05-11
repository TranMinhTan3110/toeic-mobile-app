import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_quiz_screen.dart';

class ReadingAnswersScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final List<int?> selectedIndices;

  const ReadingAnswersScreen({
    super.key,
    required this.questions,
    required this.selectedIndices,
  });

  @override
  State<ReadingAnswersScreen> createState() => _ReadingAnswersScreenState();
}

class _ReadingAnswersScreenState extends State<ReadingAnswersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<int> _filteredIndices() {
    final all = List<int>.generate(widget.questions.length, (i) => i);
    if (_tabController.index == 0) return all;
    if (_tabController.index == 1)
      return all
          .where(
            (i) =>
                widget.selectedIndices[i] == widget.questions[i].correctIndex,
          )
          .toList();
    return all
        .where(
          (i) => widget.selectedIndices[i] != widget.questions[i].correctIndex,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Hiển thị đáp án',
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary,
          ),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chọn đúng'),
            Tab(text: 'Chọn sai'),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (tabIdx) {
          final list = _filteredIndices();
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final qIndex = list[idx];
              final q = widget.questions[qIndex];
              final sel = widget.selectedIndices[qIndex];
              final correct = q.correctIndex;
              final isCorrect = sel == correct;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.error,
                      color: isCorrect ? AppColors.primary : AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Câu ${qIndex + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    // options
                    ...List.generate(q.options.length, (oi) {
                      final selected = sel == oi;
                      final bg = (oi == correct) || selected
                          ? AppColors.primary
                          : Colors.white;
                      final borderColor = AppColors.border;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? AppColors.primary : Colors.white,
                            border: Border.all(color: borderColor),
                          ),
                          child: Center(
                            child: Text(
                              '${oi + 1}',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
