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
  int _selectedCount = 1;

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
        title: 'Điền Vào Đoạn Văn',
        centerTitle: true,
        actions: [
          AppBarIconAction(icon: Icons.history, onTap: () {}),
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

        return Column(
          children: [
            // Stats header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [Text('Số câu đã làm', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(width: 8), Text('0', style: TextStyle(fontWeight: FontWeight.w800))]),
                        const SizedBox(height: 6),
                        Row(children: const [Text('Trả lời đúng', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(width: 8), Text('0', style: TextStyle(fontWeight: FontWeight.w800))]),
                        const SizedBox(height: 8),
                        const Text('Hoàn thành', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: 0,
                            minHeight: 8,
                            backgroundColor: AppColors.primaryPale,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Instruction box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Câu hỏi', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: const Text(
                    'In Part 6, you will read short passages with several blanks. Choose the best answer for each blank. Read the surrounding context carefully to determine the correct option.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ]),
            ),

            // Main content area (no preview)
            Expanded(
              child: provider.isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : Container(),
            ),

            // Bottom controls: question count + start button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              color: AppColors.background,
              child: Column(children: [
                Row(children: [
                  const Text('Số đoạn văn:', style: TextStyle(color: AppColors.textPrimary)),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _selectedCount,
                    items: const [1, 2, 3, 4, -1].map((e) {
                      final label = e == -1 ? 'Tất cả' : e.toString();
                      return DropdownMenuItem<int>(value: e, child: Text(label));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCount = v ?? 1),
                  ),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: passages.isEmpty
                        ? null
                        : () {
                            if (passages.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có đoạn văn để làm.')));
                              return;
                            }
                            final allPassages = List<ReadingPart6Passage>.from(passages);
                            allPassages.shuffle(Random());
                            final take = _selectedCount == -1 ? allPassages.length : _selectedCount.clamp(1, allPassages.length).toInt();
                            final selectedPassages = allPassages.sublist(0, take);
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart6MultiQuizScreen(passages: selectedPassages)));
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Bắt đầu nào', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textOnPrimary, fontSize: 16)),
                  ),
                ),
              ]),
            ),
          ],
        );
      }),
    );
  }
}
