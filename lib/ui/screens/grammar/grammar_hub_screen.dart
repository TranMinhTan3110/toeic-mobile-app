import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/grammar_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/grammar_model.dart';
import 'grammar_lesson_screen.dart';
import 'grammar_exercise_screen.dart';

class GrammarHubScreen extends StatefulWidget {
  const GrammarHubScreen({super.key});

  @override
  State<GrammarHubScreen> createState() => _GrammarHubScreenState();
}

class _GrammarHubScreenState extends State<GrammarHubScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<GrammarProvider>().fetchTopics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Ngữ Pháp TOEIC',
        actions: [
          // Dynamic EP display in Appbar
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final ep = userProvider.profile?.experiencePoints ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                key: const ValueKey('grammar_ep_appbar'),
                child: Row(
                  children: [
                    const Icon(Boxicons.bxs_star, color: Colors.white, size: 18),
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
              );
            },
          ),
        ],
      ),
      body: Consumer<GrammarProvider>(
        builder: (context, grammarProvider, child) {
          if (grammarProvider.isLoadingTopics) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (grammarProvider.topicsError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Boxicons.bx_wifi_off, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải chủ đề ngữ pháp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      grammarProvider.topicsError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => grammarProvider.fetchTopics(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (grammarProvider.topics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Boxicons.bx_book_open, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Hiện chưa có chủ đề ngữ pháp nào.',
                    style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          // Phân nhóm theo Category
          final tenses = grammarProvider.topics.where((t) => t.category == 'tense').toList();
          final wordForms = grammarProvider.topics.where((t) => t.category == 'word_form').toList();
          final prepositions = grammarProvider.topics.where((t) => t.category == 'preposition').toList();
          final others = grammarProvider.topics.where((t) => 
            t.category != 'tense' && t.category != 'word_form' && t.category != 'preposition').toList();

          return RefreshIndicator(
            onRefresh: () => grammarProvider.fetchTopics(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Banner giới thiệu
                _buildIntroBanner(),
                const SizedBox(height: 20),

                // Nhóm 1: Thì & Cấu trúc (Tenses)
                if (tenses.isNotEmpty) ...[
                  _buildSectionHeader('Thì & Cấu Trúc (Tenses)', Boxicons.bx_time_five, AppColors.primary),
                  ...tenses.map((topic) => _buildTopicCard(topic)),
                  const SizedBox(height: 20),
                ],

                // Nhóm 2: Từ loại (Word Forms)
                if (wordForms.isNotEmpty) ...[
                  _buildSectionHeader('Từ Loại & Nhận Dạng (Word Forms)', Boxicons.bx_font_color, AppColors.green),
                  ...wordForms.map((topic) => _buildTopicCard(topic)),
                  const SizedBox(height: 20),
                ],

                // Nhóm 3: Giới từ (Prepositions)
                if (prepositions.isNotEmpty) ...[
                  _buildSectionHeader('Giới Từ & Liên Kết (Prepositions)', Boxicons.bx_link, AppColors.blue),
                  ...prepositions.map((topic) => _buildTopicCard(topic)),
                  const SizedBox(height: 20),
                ],

                // Nhóm khác
                if (others.isNotEmpty) ...[
                  _buildSectionHeader('Chuyên Đề Khác', Boxicons.bx_category, AppColors.purple),
                  ...others.map((topic) => _buildTopicCard(topic)),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF534AB7), Color(0xFF8A7BE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33534AB7),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ngữ Pháp Trọng Tâm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hệ thống hóa toàn bộ các điểm ngữ pháp trọng tâm TOEIC Part 5 & 6 để bứt phá điểm số cao nhất.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.87),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Boxicons.bxs_graduation,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      key: ValueKey('header_${title.replaceAll(' ', '_')}'),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bx_time_five':
        return Boxicons.bx_time_five;
      case 'bx_history':
        return Boxicons.bx_history;
      case 'bx_font_color':
        return Boxicons.bx_font_color;
      case 'bx_link':
        return Boxicons.bx_link;
      case 'bx_book_open':
        return Boxicons.bx_book_open;
      default:
        return Boxicons.bx_book_reader;
    }
  }

  Widget _buildTopicCard(GrammarTopic topic) {
    // Styling values based on difficulty
    Color diffColor;
    Color diffBg;
    String diffText;
    if (topic.difficulty == 'basic') {
      diffColor = AppColors.green;
      diffBg = AppColors.greenBg;
      diffText = 'Cơ bản';
    } else if (topic.difficulty == 'intermediate') {
      diffColor = AppColors.blue;
      diffBg = AppColors.blueBg;
      diffText = 'Trung cấp';
    } else {
      diffColor = AppColors.purple;
      diffBg = AppColors.purpleBg;
      diffText = 'Nâng cao';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTopicOptionSheet(topic),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic index badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getIconData(topic.icon),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            topic.titleEn,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Difficulty badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: diffBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        diffText,
                        style: TextStyle(
                          color: diffColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  topic.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMid,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Boxicons.bx_book_open, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.lessonCount} bài học',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Boxicons.bx_check_double, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.exerciseCount} câu hỏi',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    // Action hint text
                    Row(
                      children: const [
                        Text(
                          'Học ngay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTopicOptionSheet(GrammarTopic topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Chọn chế độ học tập phù hợp',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Lựa chọn 1: Lý thuyết
              _buildOptionCard(
                title: 'Học Lý Thuyết',
                subtitle: 'Hệ thống công thức, ví dụ & dấu hiệu nhận biết',
                badgeText: '+20 EP 🔥',
                badgeColor: const Color(0xFFFFEAE6),
                badgeTextColor: const Color(0xFFFF5232),
                icon: Boxicons.bx_book_open,
                iconColor: Colors.deepPurple,
                iconBgColor: const Color(0xFFF3E8FF),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GrammarLessonScreen(topic: topic),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Lựa chọn 2: Bài tập thực hành
              _buildOptionCard(
                title: 'Luyện Bài Tập',
                subtitle: 'Thực hành trắc nghiệm Part 5 (10 câu ngẫu nhiên)',
                badgeText: '+2 EP / Câu',
                badgeColor: const Color(0xFFEAF5EA),
                badgeTextColor: const Color(0xFF2E7D32),
                icon: Boxicons.bx_check_double,
                iconColor: Colors.teal,
                iconBgColor: const Color(0xFFE0F2F1),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GrammarExerciseScreen(topic: topic),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: badgeTextColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
