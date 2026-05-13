import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part6_model.dart';
import '../../../providers/reading_part6_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_part6_quiz_screen.dart';
import 'reading_part6_multi_quiz_screen.dart';
import 'dart:math';

class ReadingPart6Screen extends StatefulWidget {
  const ReadingPart6Screen({super.key});

  @override
  State<ReadingPart6Screen> createState() => _ReadingPart6ScreenState();
}

class _ReadingPart6ScreenState extends State<ReadingPart6Screen> {
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    await context.read<ReadingPart6Provider>().fetchPassages();
    setState(() => _isInit = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Reading - Part 6',
        centerTitle: true,
        actions: [
          AppBarTextAction(
            label: 'Làm bài',
            onTap: () {
              final provider = context.read<ReadingPart6Provider>();
              final allQuestions = provider.passages.expand((p) => p.questions).toList();
              if (allQuestions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có câu hỏi để làm.')));
                return;
              }

              allQuestions.shuffle(Random());
              // ensure at least 16 items (4 passages * 4 questions)
              final pool = <ReadingPart6Question>[]..addAll(allQuestions);
              while (pool.length < 16) {
                pool.addAll(allQuestions);
              }
              final selected = pool.sublist(0, 16);

              final passageTexts = provider.passages.map((p) => p.passage).toList();
              final quizPassages = <ReadingPart6Passage>[];
              for (var i = 0; i < 4; i++) {
                final group = selected.sublist(i * 4, i * 4 + 4);
                final passageText = passageTexts.isNotEmpty ? passageTexts[i % passageTexts.length] : '';
                quizPassages.add(ReadingPart6Passage(id: 'auto-${i + 1}', passage: passageText, questions: group));
              }

              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart6MultiQuizScreen(passages: quizPassages)));
            },
          ),
        ],
      ),
      body: Consumer<ReadingPart6Provider>(builder: (context, provider, child) {
        if (provider.isLoading && _isInit) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: LinearProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.errorMessage != null && _isInit) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)), const SizedBox(height: 8), ElevatedButton(onPressed: _load, child: const Text('Thử lại'))]),
          );
        }

        final passages = provider.passages;
        return Column(children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : passages.isEmpty
                    ? const Center(child: Text('Không có nội dung Part6.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: passages.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final p = passages[idx];
                          return ListTile(
                            title: Text('Đoạn ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(p.passage, maxLines: 3, overflow: TextOverflow.ellipsis),
                            trailing: Text('${p.questions.length} câu'),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart6QuizScreen(passage: p)));
                            },
                          );
                        },
                      ),
          ),
        ]);
      }),
    );
  }
}
