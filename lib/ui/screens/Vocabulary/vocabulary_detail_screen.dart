import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../widgets/vocabulary/detail_tabs/basic_info_tab.dart';
import '../../widgets/vocabulary/detail_tabs/examples_tab.dart';
import '../../widgets/vocabulary/detail_tabs/related_words_tab.dart';
import '../../../core/services/tts_service.dart'; 

import '../../widgets/common/custom_app_bar.dart';
import 'vocabulary_ai_writing_screen.dart';
class VocabularyDetailScreen extends StatefulWidget {
  final VocabularyModel word;

  const VocabularyDetailScreen({super.key, required this.word});

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  late bool _isStarred;

  @override
  void initState() {
    super.initState();
    _isStarred = widget.word.isStarred;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Chi tiết từ vựng',
          centerTitle: true,
          actions: [
            AppBarIconAction(
              icon: _isStarred ? Icons.star : Icons.star_border,
              color: _isStarred ? AppColors.star : Colors.white,
              onTap: () {
                setState(() {
                  _isStarred = !_isStarred;
                });
                // Logic sync to provider/backend would go here
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Từ vựng'),
              Tab(text: 'Mẫu câu'),
              Tab(text: 'Liên quan'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header Section: Word & Phonetic
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 16),
              child: Column(
                children: [
                  Text(
                    widget.word.word,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.word.phonetic,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          TtsService().speak(widget.word.word);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TabContent Section
            Expanded(
              child: TabBarView(
                children: [
                  BasicInfoTab(word: widget.word),
                  ExamplesTab(examples: widget.word.examples),
                  RelatedWordsTab(
                    synonyms: widget.word.synonyms,
                    antonyms: widget.word.antonyms,
                    collocations: widget.word.collocations,
                  ),
                ],
              ),
            ),

            // AI Practice Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyAiWritingScreen(
                          words: [widget.word],
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text(
                    'Luyện viết câu với AI',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
