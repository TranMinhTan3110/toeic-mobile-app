import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../widgets/vocabulary/detail_tabs/basic_info_tab.dart';
import '../../widgets/vocabulary/detail_tabs/examples_tab.dart';
import '../../widgets/vocabulary/detail_tabs/related_words_tab.dart';
import '../../../core/services/tts_service.dart'; 

class VocabularyDetailScreen extends StatelessWidget {
  final VocabularyModel word;

  const VocabularyDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Chi tiết từ vựng',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                word.isStarred ? Icons.star : Icons.star_border,
                color: Colors.white,
              ),
              onPressed: () {
                // Logic toggle star
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Header Section: Word & Phonetic
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Column(
                children: [
                  Text(
                    word.word,
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
                        word.phonetic,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          // Phát âm từ chính bằng TTS
                          TtsService().speak(word.word);
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

            // TabBar Section
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: const TabBar(
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

            // TabContent Section
            Expanded(
              child: TabBarView(
                children: [
                  BasicInfoTab(word: word),
                  ExamplesTab(examples: word.examples),
                  RelatedWordsTab(
                    synonyms: word.synonyms,
                    antonyms: word.antonyms,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
