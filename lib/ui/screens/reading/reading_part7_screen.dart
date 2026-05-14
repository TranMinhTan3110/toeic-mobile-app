import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part7_model.dart';
import '../../../providers/reading_part7_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_part7_quiz_screen.dart';
import 'reading_part7_multi_quiz_screen.dart';

class ReadingPart7Screen extends StatefulWidget {
  const ReadingPart7Screen({super.key});

  @override
  State<ReadingPart7Screen> createState() => _ReadingPart7ScreenState();
}

class _ReadingPart7ScreenState extends State<ReadingPart7Screen> {
  bool _isInit = true;
  // default must match one of the dropdown items below
  int _selectedCount = 10;

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
      appBar: CustomAppBar(
        title: 'Đọc Hiểu Đoạn Văn',
        centerTitle: true,
        actions: [AppBarIconAction(icon: Icons.history, onTap: () {})],
      ),
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

        return Column(
          children: [
            // header
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
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Đọc hiểu', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text('Chuẩn bị làm Part 7', style: TextStyle(color: AppColors.textSecondary)),
                    ]),
                  ),
                ],
              ),
            ),

            // instruction
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Hướng dẫn', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))]),
                  child: const Text('Chọn số đoạn văn muốn làm, sau đó nhấn Bắt đầu.', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ]),
            ),

            // main
            Expanded(child: provider.isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : Container()),

            // bottom controls
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              color: AppColors.background,
              child: Column(children: [
                Row(children: [
                  const Text('Số đoạn văn:', style: TextStyle(color: AppColors.textPrimary)),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _selectedCount,
                    items: const [5, 10, 15, -1].map((e) {
                      final label = e == -1 ? 'Tất cả' : e.toString();
                      return DropdownMenuItem<int>(value: e, child: Text(label));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCount = v ?? 10),
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
                            final allPassages = List<ReadingPart7Passage>.from(passages);
                            allPassages.shuffle(Random());
                            final take = _selectedCount == -1 ? allPassages.length : _selectedCount.clamp(1, allPassages.length).toInt();
                            final selectedPassages = allPassages.sublist(0, take);

                            if (selectedPassages.length == 1) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart7QuizScreen(passage: selectedPassages.first)));
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart7MultiQuizScreen(passages: selectedPassages)));
                            }
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
