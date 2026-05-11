import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/home/promo_banner.dart';
import '../../widgets/home/skill_card.dart';
import '../../widgets/home/exam_card.dart';
import '../../widgets/home/section_title.dart';
import '../../widgets/common/home_bottom_nav.dart';
import '../../widgets/history/history_section.dart';
import '../../../data/models/history_item_model.dart';
import '../../widgets/home/notebook_section.dart';
import '../reading/reading_screen.dart';
import '../practice/writing/writing_screen.dart';
import '../listening/listening_screen.dart';
import '../exam/test_list_screen.dart';
import '../Vocabulary/vocabulary_screen.dart';
import '../speaking/speaking_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  // ── Dữ liệu luyện tập ──────────────────────────────────────────────
  static const _practiceItems = [
    (
      label: 'Nghe Hiểu',
      icon: Icons.headphones,
      color: AppColors.primary,
      bg: AppColors.primaryPale,
      progress: 0.65,
    ),
    (
      label: 'Đọc Hiểu',
      icon: Icons.menu_book,
      color: AppColors.green,
      bg: AppColors.greenBg,
      progress: 0.42,
    ),
    (
      label: 'Luyện Nói',
      icon: Icons.mic,
      color: AppColors.blue,
      bg: AppColors.blueBg,
      progress: 0.30,
    ),
    (
      label: 'Viết',
      icon: Icons.edit,
      color: AppColors.purple,
      bg: AppColors.purpleBg,
      progress: 0.20,
    ),
  ];

  static const _examItems = [
    (
      label: 'Thi Thử',
      icon: Icons.assignment_turned_in,
      color: AppColors.primary,
      bg: AppColors.primaryPale,
      badge: 'HOT',
      badgeColor: AppColors.primary,
    ),
    (
      label: 'Từ Vựng',
      icon: Icons.translate,
      color: AppColors.green,
      bg: AppColors.greenBg,
      badge: null,
      badgeColor: null,
    ),
    (
      label: 'Ngữ Pháp',
      icon: Icons.spellcheck,
      color: AppColors.blue,
      bg: AppColors.blueBg,
      badge: null,
      badgeColor: null,
    ),
    (
      label: 'Cài Đặt',
      icon: Icons.settings,
      color: AppColors.primary,
      bg: AppColors.primaryPale,
      badge: null,
      badgeColor: null,
    ),
  ];

  // ── Dữ liệu lịch sử ─────────────
  final List<HistoryItem> _practiceHistory = [
    HistoryItem(
      title: 'Điền Vào Câu',
      type: 'Luyện tập',
      percent: 15,
      date: DateTime.now(),
    ),
    HistoryItem(
      title: 'Nghe Hiểu Part 1',
      type: 'Luyện tập',
      percent: 30,
      date: DateTime.now(),
    ),
    HistoryItem(
      title: 'Đọc Hiểu',
      type: 'Luyện tập',
      percent: 30,
      date: DateTime.now(),
    ),
  ];

  final List<HistoryItem> _examHistory = [
    HistoryItem(
      title: 'Đề Thi Thử 01',
      type: 'Thi',
      percent: 60,
      date: DateTime.now(),
    ),
    HistoryItem(
      title: 'Đề Thi Thử 02',
      type: 'Thi',
      percent: 75,
      date: DateTime.now(),
    ),
    HistoryItem(
      title: 'Đề Thi Thử 03',
      type: 'Thi',
      percent: 75,
      date: DateTime.now(),
    ),
    HistoryItem(
      title: 'Đề Thi Thử 04',
      type: 'Thi',
      percent: 75,
      date: DateTime.now(),
    ),
    HistoryItem(
      title: 'Đề Thi Thử 05',
      type: 'Thi',
      percent: 75,
      date: DateTime.now(),
    ),
    HistoryItem(
      title: 'Đề Thi Thử 06',
      type: 'Thi',
      percent: 75,
      date: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(
            title: 'Trang chủ',
            centerTitle: true,
            showBackButton: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PromoBanner(),
                  _buildPracticeSection(),
                  _buildExamSection(),
                  // ── Lịch sử ──────────────────────────────────
                  HistorySection(
                    practiceItems: _practiceHistory,
                    examItems: _examHistory,
                    previewCount: 5,
                  ),
                  // ── Sổ tay ───────────────────────────────────
                  NotebookSection(
                    vocabularyCount: 0,       // TODO: lấy từ DB
                    questionCount: 0,          // TODO: lấy từ DB
                    onVocabReview: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VocabularyScreen()),
                      );
                    },
                    onQuestionReview: () {},
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _buildPracticeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'luyện tập 4 kỹ năng toiec'),
          const SizedBox(height: 14),
          Row(
                children: _practiceItems
                .map((e) => Expanded(
              child: SkillCard(
                label: e.label, icon: e.icon,
                iconColor: e.color, iconBg: e.bg,
                progress  : e.progress,
                onTap: () {
                  if (e.label == 'Đọc Hiểu') {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ReadingScreen(practiceHistory: _practiceHistory),
                    ));
                  } else if (e.label == 'Nghe Hiểu') {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ListeningScreen(),
                    ));
                  } else if (e.label == 'Viết') {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const WritingScreen(),
                    ));
                  } else if (e.label == 'Luyện Nói') {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SpeakingScreen(),
                    ));
                  }
                },
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExamSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Luyện thi'),
          const SizedBox(height: 14),
          Row(
            children: _examItems
                .map(
                  (e) => Expanded(
                    child: ExamCard(
                      label: e.label,
                      icon: e.icon,
                      iconColor: e.color,
                      iconBg: e.bg,
                      badge: e.badge,
                      badgeColor: e.badgeColor,
                      onTap: () {
                        if (e.label == 'Thi Thử') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TestListScreen(),
                            ),
                          );
                        } else if (e.label == 'Từ Vựng') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VocabularyScreen(),
                            ),
                          );
                        } else {
                          // TODO: Xử lý cho Ngữ Pháp, Cài Đặt
                        }
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
