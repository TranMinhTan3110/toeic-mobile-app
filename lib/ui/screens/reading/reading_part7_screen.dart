import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part7_model.dart';
import '../../../providers/reading_part7_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_part7_quiz_screen.dart';

class ReadingPart7Screen extends StatefulWidget {
  const ReadingPart7Screen({super.key});

  @override
  State<ReadingPart7Screen> createState() => _ReadingPart7ScreenState();
}

class _ReadingPart7ScreenState extends State<ReadingPart7Screen> {
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    await context.read<ReadingPart7Provider>().fetchPassages();
    setState(() => _isInit = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Reading - Part 7', centerTitle: true),
      body: Consumer<ReadingPart7Provider>(builder: (context, provider, child) {
        if (provider.isLoading && _isInit) {
          return const Padding(padding: EdgeInsets.all(16.0), child: LinearProgressIndicator(color: AppColors.primary));
        }

        if (provider.errorMessage != null && _isInit) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)), const SizedBox(height: 8), ElevatedButton(onPressed: _load, child: const Text('Thử lại'))]),
          );
        }

        final passages = provider.passages;
        return Column(children: [
          // Instructions + start button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hướng dẫn làm Part 7', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Đọc kỹ đoạn văn (email, thông báo, đoạn hội thoại...), sau đó trả lời các câu hỏi liên quan. Mỗi đoạn có nhiều câu; hãy chú ý tham chiếu giữa các câu để tìm đáp án chính xác.', style: TextStyle(color: Colors.black87)),
              const SizedBox(height: 12),
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (passages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có câu hỏi để làm.')));
                        return;
                      }
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart7QuizScreen(passage: passages[0])));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Làm bài', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                ),
              )
            ]),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : passages.isEmpty
                    ? const Center(child: Text('Không có nội dung Part7.'))
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
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart7QuizScreen(passage: p)));
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
