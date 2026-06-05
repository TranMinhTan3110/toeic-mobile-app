import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/practice_dialogs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/speaking_provider.dart';
import '../../../providers/listening_provider.dart';
import '../../../providers/writing_provider.dart';
import '../../../providers/vocabulary_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/reading_part5_provider.dart';
import '../../../providers/reading_part6_provider.dart';
import '../../../providers/reading_part7_provider.dart';
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
import '../Vocabulary/vocabulary_hub_screen.dart';
import '../grammar/grammar_hub_screen.dart';
import '../profile/profile_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../settings/settings_screen.dart';
import '../speaking/speaking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        context.read<UserProvider>().fetchProfile();
        // Load lịch sử các kỹ năng để đảm bảo dữ liệu sẵn sàng ngoài trang chủ
        context.read<SpeakingProvider>().fetchHistory();
        context.read<ListeningProvider>().fetchHistory();
        context.read<WritingProvider>().fetchHistory();
        context.read<ReadingPart5Provider>().fetchHistory();
        context.read<ReadingPart6Provider>().fetchHistory();
        context.read<ReadingPart7Provider>().fetchHistory();
        context.read<ExamProvider>().fetchSpeakingExamHistory();
        context.read<ExamProvider>().fetchWritingExamHistory();
        context.read<ExamProvider>().fetchFullTestHistory();
        // Load thông số từ vựng cần ôn ở sổ tay
        context.read<VocabularyProvider>().fetchHubStats(forceRefresh: true);

        // Check welcome dialog flag
        try {
          final prefs = await SharedPreferences.getInstance();
          final showWelcome = prefs.getBool('show_welcome_dialog') ?? false;
          if (showWelcome && mounted) {
            showPremiumSuccessDialog(
              context,
              title: 'Chào mừng thành viên mới!',
              text: 'Chào mừng bạn đến với TOEIC Master! Hãy cùng nhau chinh phục điểm số TOEIC mục tiêu nhé.',
            );
            await prefs.setBool('show_welcome_dialog', false);
          }
        } catch (e) {
          debugPrint('Lỗi hiển thị welcome dialog: $e');
        }
      }
    });
  }

  // ── Dữ liệu luyện tập ──────────────────────────────────────────────
  static final _practiceItems = [
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
      icon: Boxicons.bx_edit_alt,
      color: AppColors.purple,
      bg: AppColors.purpleBg,
      progress: 0.20,
    ),
  ];

  static final _examItems = [
    (
      label: 'Thi Thử',
      icon: Boxicons.bxs_graduation,
      color: AppColors.primary,
      bg: AppColors.primaryPale,
      badge: 'HOT',
      badgeColor: AppColors.primary,
    ),
    (
      label: 'Từ Vựng',
      icon: Boxicons.bx_book_open,
      color: AppColors.green,
      bg: AppColors.greenBg,
      badge: null,
      badgeColor: null,
    ),
    (
      label: 'Ngữ Pháp',
      icon: Boxicons.bx_check_double,
      color: AppColors.blue,
      bg: AppColors.blueBg,
      badge: null,
      badgeColor: null,
    ),
    (
      label: 'Cài Đặt',
      icon: Boxicons.bx_cog,
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
      icon: Icons.edit_note_rounded,
      color: AppColors.purple,
    ),
    HistoryItem(
      title: 'Nghe Hiểu Part 1',
      type: 'Luyện tập',
      percent: 30,
      date: DateTime.now(),
      icon: Icons.headphones_rounded,
      color: AppColors.primary,
    ),
    HistoryItem(
      title: 'Đọc Hiểu',
      type: 'Luyện tập',
      percent: 30,
      date: DateTime.now(),
      icon: Icons.menu_book_rounded,
      color: AppColors.green,
    ),
  ];

  final List<HistoryItem> _examHistory = [
    HistoryItem(
      title: 'Đề Thi Thử 01',
      type: 'Thi',
      percent: 60,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HistoryItem(
      title: 'Đề Thi Thử 02',
      type: 'Thi',
      percent: 75,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HistoryItem(
      title: 'Đề Thi Thử 03',
      type: 'Thi',
      percent: 75,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildHomeTabContent(), // 0: Trang Chủ
          TestListScreen(
            onBack: () => setState(() => _navIndex = 0),
          ), // 1: Đề thi
          const LeaderboardScreen(), // 2: BXH
          const ProfileScreen(), // 3: Hồ sơ
          SettingsScreen(
            onBack: () => setState(() => _navIndex = 0),
          ), // 4: Cài đặt
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _buildHomeTabContent() {
    final speakingProvider = context.watch<SpeakingProvider>();
    final listeningProvider = context.watch<ListeningProvider>();
    final writingProvider = context.watch<WritingProvider>();
    final readingPart5Provider = context.watch<ReadingPart5Provider>();
    final readingPart6Provider = context.watch<ReadingPart6Provider>();
    final readingPart7Provider = context.watch<ReadingPart7Provider>();
    final vocabProvider = context.watch<VocabularyProvider>();
    final examProvider = context.watch<ExamProvider>();

    final vocabDueCount = vocabProvider.hubStats?.dueCount ?? 0;

    final List<HistoryItem> mergedHistory = [];

    // 1. Map Speaking history
    for (final item in speakingProvider.historyItems) {
      DateTime parsedDate;
      try {
        final cleanDate = item.date.contains('-')
            ? item.date.split('-')[1].trim()
            : item.date.trim();
        final parts = cleanDate.split('/');
        parsedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (_) {
        parsedDate = DateTime.now();
      }

      mergedHistory.add(
        HistoryItem(
          title: item.partTitle,
          date: parsedDate,
          percent: item.score * 10.0,
          type: 'Luyện tập',
          icon: Icons.mic_rounded,
          color: AppColors.blue,
        ),
      );
    }

    // 2. Map Writing history
    for (final item in writingProvider.historyItems) {
      final partNumber = item.taskNumber ?? 0;
      final label = item.taskTypeLabel == '-' ? 'Writing' : item.taskTypeLabel;
      final title = partNumber > 0 ? 'Phần $partNumber - $label' : label;

      mergedHistory.add(
        HistoryItem(
          title: title,
          date: item.submittedAt,
          percent: item.aiScore != null
              ? (item.aiScore!.toDouble() * 10.0)
              : 0.0,
          type: 'Luyện tập',
          icon: Icons.draw_rounded,
          color: AppColors.purple,
        ),
      );
    }

    // 3. Map Listening history
    for (final item in listeningProvider.history) {
      String partTitle = '';
      switch (item.part) {
        case 1:
          partTitle = 'Phần 1 - Mô tả tranh';
          break;
        case 2:
          partTitle = 'Phần 2 - Phản hồi yêu cầu';
          break;
        case 3:
          partTitle = 'Phần 3 - Đoạn hội thoại';
          break;
        case 4:
          partTitle = 'Phần 4 - Bài nói chuyện ngắn';
          break;
        default:
          partTitle = 'Phần ${item.part}';
      }

      mergedHistory.add(
        HistoryItem(
          title: partTitle,
          date: item.date,
          percent: item.totalCount > 0
              ? (item.correctCount * 100.0 / item.totalCount)
              : 0.0,
          type: 'Luyện tập',
          icon: Icons.headphones_rounded,
          color: AppColors.primary,
        ),
      );
    }

    // 4. Map Reading Part 5 history
    for (final item in readingPart5Provider.history) {
      mergedHistory.add(
        HistoryItem(
          title: 'Phần 5 - Điền Vào Câu',
          date: item.date,
          percent: item.percent,
          type: 'Luyện tập',
          icon: Icons.menu_book_rounded,
          color: AppColors.green,
        ),
      );
    }

    // 5. Map Reading Part 6 history
    for (final item in readingPart6Provider.history) {
      mergedHistory.add(
        HistoryItem(
          title: 'Phần 6 - Điền Vào Đoạn Văn',
          date: item.date,
          percent: item.percent,
          type: 'Luyện tập',
          icon: Icons.menu_book_rounded,
          color: AppColors.green,
        ),
      );
    }

    // 6. Map Reading Part 7 history
    for (final item in readingPart7Provider.history) {
      mergedHistory.add(
        HistoryItem(
          title: 'Phần 7 - Đọc Hiểu Đoạn Văn',
          date: item.date,
          percent: item.percent,
          type: 'Luyện tập',
          icon: Icons.menu_book_rounded,
          color: AppColors.green,
        ),
      );
    }

    final List<HistoryItem> finalPracticeHistory;
    if (mergedHistory.isEmpty) {
      finalPracticeHistory = [];
    } else {
      mergedHistory.sort((a, b) => b.date.compareTo(a.date));
      finalPracticeHistory = mergedHistory.take(3).toList();
    }

    final List<HistoryItem> mergedExamHistory = [];

    // 1. Map Speaking Exam History
    for (final item in examProvider.speakingExamHistories) {
      mergedExamHistory.add(
        HistoryItem(
          title: item.examTitle,
          date: item.date,
          percent: (item.toeicScore / 200.0) * 100.0,
          type: 'Thi',
          icon: Icons.mic_rounded,
          color: AppColors.blue,
        ),
      );
    }

    // 2. Map Writing Exam History
    for (final item in examProvider.writingExamHistories) {
      mergedExamHistory.add(
        HistoryItem(
          title: item.examTitle,
          date: item.date,
          percent: (item.toeicScore / 200.0) * 100.0,
          type: 'Thi',
          icon: Icons.draw_rounded,
          color: AppColors.purple,
        ),
      );
    }

    // 3. Map Full Test Exam History
    for (final item in examProvider.fullTestHistories) {
      mergedExamHistory.add(
        HistoryItem(
          title: item.examTitle,
          date: item.completedAt,
          percent: item.totalCount > 0
              ? (item.correctCount * 100.0 / item.totalCount)
              : 0.0,
          type: 'Thi',
          icon: Icons.assignment_rounded,
          color: AppColors.primary,
        ),
      );
    }

    final List<HistoryItem> finalExamHistory;
    if (mergedExamHistory.isEmpty) {
      finalExamHistory = [];
    } else {
      mergedExamHistory.sort((a, b) => b.date.compareTo(a.date));
      finalExamHistory = mergedExamHistory.take(3).toList();
    }

    return Column(
      children: [
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final profile = userProvider.profile;
            final streak = profile?.streakDays ?? 0;
            final ep = profile?.experiencePoints ?? 0;

            return CustomAppBar(
              title: 'TOEIC Master',
              centerTitle: false,
              showBackButton: false,
              actions: [
                // Icon Lửa Streak
                Row(
                  children: [
                    const Icon(
                      Boxicons.bxs_flame,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Icon Điểm EP
                Row(
                  children: [
                    const Icon(
                      Boxicons.bxs_star,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$ep EP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            );
          },
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
                  practiceItems: finalPracticeHistory,
                  examItems: finalExamHistory,
                  previewCount: 3,
                ),
                // ── Sổ tay ───────────────────────────────────
                NotebookSection(
                  vocabularyCount: vocabDueCount,
                  questionCount: 0, // TODO: lấy từ DB
                  onVocabReview: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VocabularyHubScreen(),
                      ),
                    ).then((_) {
                      if (mounted) {
                        context.read<VocabularyProvider>().fetchHubStats(
                          forceRefresh: true,
                        );
                      }
                    });
                  },
                  onQuestionReview: () {},
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
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
                .map(
                  (e) => Expanded(
                    child: SkillCard(
                      label: e.label,
                      icon: e.icon,
                      iconColor: e.color,
                      iconBg: e.bg,
                      progress: e.progress,
                      onTap: () {
                        if (e.label == 'Đọc Hiểu') {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => const ReadingScreen(),
                                ),
                              )
                              .then((_) {
                                if (mounted) {
                                  context.read<UserProvider>().fetchProfile(
                                    forceRefresh: true,
                                  );
                                  context
                                      .read<ReadingPart5Provider>()
                                      .fetchHistory();
                                  context
                                      .read<ReadingPart6Provider>()
                                      .fetchHistory();
                                  context
                                      .read<ReadingPart7Provider>()
                                      .fetchHistory();
                                }
                              });
                        } else if (e.label == 'Nghe Hiểu') {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => const ListeningScreen(),
                                ),
                              )
                              .then((_) {
                                if (mounted) {
                                  context.read<UserProvider>().fetchProfile(
                                    forceRefresh: true,
                                  );
                                  context
                                      .read<ListeningProvider>()
                                      .fetchHistory();
                                }
                              });
                        } else if (e.label == 'Viết') {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => const WritingScreen(),
                                ),
                              )
                              .then((_) {
                                if (mounted) {
                                  context.read<UserProvider>().fetchProfile(
                                    forceRefresh: true,
                                  );
                                  context
                                      .read<WritingProvider>()
                                      .fetchHistory();
                                  context
                                      .read<ExamProvider>()
                                      .fetchWritingExamHistory();
                                }
                              });
                        } else if (e.label == 'Luyện Nói') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SpeakingScreen(),
                            ),
                          ).then((_) {
                            if (mounted) {
                              context.read<UserProvider>().fetchProfile(
                                forceRefresh: true,
                              );
                              context.read<SpeakingProvider>().fetchHistory();
                              context
                                  .read<ExamProvider>()
                                  .fetchSpeakingExamHistory();
                            }
                          });
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
                          ).then((_) {
                            if (mounted) {
                              context
                                  .read<ExamProvider>()
                                  .fetchSpeakingExamHistory();
                              context
                                  .read<ExamProvider>()
                                  .fetchWritingExamHistory();
                            }
                          });
                        } else if (e.label == 'Từ Vựng') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VocabularyHubScreen(),
                            ),
                          );
                        } else if (e.label == 'Cài Đặt') {
                          setState(() => _navIndex = 4);
                        } else if (e.label == 'Ngữ Pháp') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GrammarHubScreen(),
                            ),
                          );
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
