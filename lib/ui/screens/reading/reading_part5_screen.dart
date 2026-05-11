import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/reading_part5_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_part5_quiz_screen.dart';
import '../../widgets/common/practice_result_view.dart';

class ReadingPart5Screen extends StatefulWidget {
  const ReadingPart5Screen({super.key});

  @override
  State<ReadingPart5Screen> createState() => _ReadingPart5ScreenState();
}

class _ReadingPart5ScreenState extends State<ReadingPart5Screen> {
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    await context.read<ReadingPart5Provider>().fetchQuestions();
    setState(() => _isInit = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Reading - Part 5', centerTitle: true),
      body: Consumer<ReadingPart5Provider>(
        builder: (context, provider, child) {
          if (provider.isLoading && _isInit) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null && _isInit) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
                ],
              ),
            );
          }

          final questions = provider.questions;
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                child: Row(children: [
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.article, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Luyện Part 5', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 6), Text('Bài tập điền vào chỗ trống, chọn đáp án đúng.')])),
                  ElevatedButton(onPressed: questions.isEmpty ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart5QuizScreen(questions: questions))), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Làm bài')),
                ]),
              ),

              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : questions.isEmpty
                        ? const Center(child: Text('Không có câu hỏi Part5.'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: questions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final q = questions[idx];
                              return ListTile(
                                title: Text('Câu ${idx + 1}: ${q.prompt}', maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart5QuizScreen(questions: [q], startIndex: 0)));
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
