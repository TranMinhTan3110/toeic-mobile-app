import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/home/section_title.dart';
import 'reading_detail_screen.dart';
import 'reading_part5_screen.dart';
import '../../../data/models/history_item_model.dart';
import '../../widgets/history/reading_history_section.dart';
import '../../widgets/reading/reading_section_card.dart';
import 'part6_screen.dart';
import 'part7_screen.dart';

class ReadingScreen extends StatelessWidget {
  final List<HistoryItem> practiceHistory;

  const ReadingScreen({super.key, this.practiceHistory = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'Đọc Hiểu', centerTitle: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      children: const [
                        SectionTitle(title: 'Phần đọc hiểu'),
                        SizedBox(height: 14),
                      ],
                    ),
                  ),
                  _buildSectionsList(context),
                  const SizedBox(height: 12),
                  _buildWrongPracticeCard(),
                  // Lịch sử làm bài nằm dưới phần "Luyện tập câu sai"
                  ReadingHistorySection(
                    items: practiceHistory,
                    previewCount: 5,
                    onSeeAll: () {
                      // fallback: open full history sheet if needed
                      // We call the existing full-sheet show if it exists.
                      // Importing HistoryFullSheet here would create a dependency; keep simple.
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
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
                  Row(
                    children: const [
                      Text('Số câu đã làm', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Text('0', style: TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Text('Trả lời đúng', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Text('0', style: TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
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
    );
  }

  Widget _buildSectionsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          ReadingSectionCard(
            title: 'Phần 5 - Điền Vào Câu',
            correctCount: '0/0',
            showLock: false,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReadingPart5Screen()));
            },
          ),
          const SizedBox(height: 12),
          ReadingSectionCard(
            title: 'Phần 6 - Điền Vào Đoạn Văn',
            correctCount: '0/0',
            showLock: false,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Part6Screen()));
            },
          ),
          const SizedBox(height: 12),
          ReadingSectionCard(title: 'Phần 7 - Đọc Hiểu Đoạn Văn', correctCount: '0/0', showLock: false, onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Part7Screen())); }),
        ],
      ),
    );
  }

  Widget _buildWrongPracticeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Luyện tập câu sai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Số câu hỏi: 0', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
