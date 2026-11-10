import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/full_test_history_model.dart';
import '../../../providers/exam_provider.dart';
import '../../../data/models/listening_question.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'full_test_history_swipe_screen.dart';

class FullTestHistoryOverviewScreen extends StatefulWidget {
  final FullTestHistoryModel historyItem;
  const FullTestHistoryOverviewScreen({super.key, required this.historyItem});

  @override
  State<FullTestHistoryOverviewScreen> createState() => _FullTestHistoryOverviewScreenState();
}

class _FullTestHistoryOverviewScreenState extends State<FullTestHistoryOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _activeFilter = 'Tất cả'; // 'Tất cả', 'Chọn đúng', 'Chọn sai'

  List<ListeningQuestion> _listeningQuestions = [];
  List<ListeningQuestion> _readingQuestions = [];
  Map<String, ListeningGroup> _questionGroups = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final provider = context.read<ExamProvider>();
    if (provider.examItems.isEmpty || provider.examItems.first.examId != widget.historyItem.examId) {
      setState(() => _isLoading = true);
      try {
        await provider.fetchExamQuestions(widget.historyItem.examId);
      } catch (e) {
        debugPrint('Error loading exam questions: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
    _splitQuestions();
  }

  void _splitQuestions() {
    final provider = context.read<ExamProvider>();
    final list = provider.examItems;
    final List<ListeningQuestion> listening = [];
    final List<ListeningQuestion> reading = [];
    final Map<String, ListeningGroup> groups = {};

    for (var item in list) {
      if (item is ListeningQuestion) {
        if (item.part <= 4) {
          listening.add(item);
        } else {
          reading.add(item);
        }
      } else if (item is ListeningGroup) {
        for (var q in item.questions) {
          groups[q.id] = item;
          if (item.part <= 4) {
            listening.add(q);
          } else {
            reading.add(q);
          }
        }
      }
    }

    setState(() {
      _listeningQuestions = listening;
      _readingQuestions = reading;
      _questionGroups = groups;
    });
  }

  List<ListeningQuestion> _getFiltered(List<ListeningQuestion> originalList) {
    return originalList.where((q) {
      final selectedAns = widget.historyItem.answers[q.id];
      final correctAns = PracticeOptionParser.normalizeCorrectKey(
        q.correctAnswer,
        options: q.options,
      );
      final isCorrect = selectedAns == correctAns;

      if (_activeFilter == 'Chọn đúng') return isCorrect;
      if (_activeFilter == 'Chọn sai') return !isCorrect;
      return true;
    }).toList();
  }

  String _getPartTitle(int part) {
    switch (part) {
      case 1:
        return 'Part 1: Mô tả tranh (Photographs)';
      case 2:
        return 'Part 2: Hỏi & Đáp (Question-Response)';
      case 3:
        return 'Part 3: Hội thoại ngắn (Short Conversations)';
      case 4:
        return 'Part 4: Bài nói ngắn (Short Talks)';
      case 5:
        return 'Part 5: Hoàn thành câu (Incomplete Sentences)';
      case 6:
        return 'Part 6: Hoàn thành đoạn văn (Text Completion)';
      case 7:
        return 'Part 7: Đọc hiểu đoạn văn (Reading Comprehension)';
      default:
        return 'Part $part';
    }
  }

  @override
  Widget build(BuildContext context) {
    final allQuestions = _listeningQuestions + _readingQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // --- HEADER ---
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32), // Spacer
                        const Text(
                          'Tổng quan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // --- TABS (Listening & Reading) ---
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: 'Listening'),
                        Tab(text: 'Reading'),
                      ],
                    ),
                  ),

                  // --- FILTER PILLS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterPill('Tất cả'),
                        const SizedBox(width: 10),
                        _buildFilterPill('Chọn đúng'),
                        const SizedBox(width: 10),
                        _buildFilterPill('Chọn sai'),
                      ],
                    ),
                  ),

                  // --- QUESTION LIST TABS ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildQuestionsList(_listeningQuestions, allQuestions),
                        _buildQuestionsList(_readingQuestions, allQuestions),
                      ],
                    ),
                  ),

                  // --- BOTTOM TELEPROMPTER BAR ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: AppColors.primary,
                    child: const Text(
                      'Ấn vào từng câu để xem giải thích chi tiết',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isActive = _activeFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: Colors.grey[400]!, width: 1)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList(List<ListeningQuestion> questions, List<ListeningQuestion> allQuestions) {
    final filtered = _getFiltered(questions);
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Không có câu hỏi nào khớp với bộ lọc.',
          style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8)),
        ),
      );
    }

    // Group by part
    final Map<int, List<ListeningQuestion>> groupedByPart = {};
    for (var q in filtered) {
      groupedByPart.putIfAbsent(q.part, () => []).add(q);
    }

    final sortedParts = groupedByPart.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedParts.length,
      itemBuilder: (context, partIdx) {
        final part = sortedParts[partIdx];
        final partQuestions = groupedByPart[part]!;
        final partTitle = _getPartTitle(part);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 16),
              child: Text(
                partTitle,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ...partQuestions.map((q) {
              final globalIndex = allQuestions.indexWhere((x) => x.id == q.id);
              return _buildQuestionRow(q, globalIndex >= 0 ? globalIndex : 0, questions);
            }),
          ],
        );
      },
    );
  }

  Widget _buildQuestionRow(ListeningQuestion q, int globalIndex, List<ListeningQuestion> tabQuestions) {
    final selectedAns = widget.historyItem.answers[q.id];
    final questionNumber = globalIndex + 1;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullTestHistorySwipeScreen(
              historyItem: widget.historyItem,
              tabQuestions: tabQuestions,
              questionGroups: _questionGroups,
              startIndex: tabQuestions.indexWhere((x) => x.id == q.id),
              allQuestions: _listeningQuestions + _readingQuestions,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Câu $questionNumber',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            _buildChoiceCircles(q, selectedAns),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCircles(ListeningQuestion q, String? selectedAns) {
    final correctAns = PracticeOptionParser.normalizeCorrectKey(
      q.correctAnswer,
      options: q.options,
    );
    final totalOptions = q.options.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalOptions, (idx) {
        final optionKey = String.fromCharCode(65 + idx); // A, B, C, D
        final displayNum = '${idx + 1}'; // 1, 2, 3, 4

        final isSelected = selectedAns == optionKey;
        final isCorrect = correctAns == optionKey;

        Color bgColor = Colors.white;
        Color textColor = AppColors.textPrimary;
        Color borderColor = AppColors.divider;

        if (isCorrect) {
          bgColor = AppColors.green;
          textColor = Colors.white;
          borderColor = AppColors.green;
        } else if (isSelected) {
          bgColor = Colors.red;
          textColor = Colors.white;
          borderColor = Colors.red;
        }

        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              displayNum,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
