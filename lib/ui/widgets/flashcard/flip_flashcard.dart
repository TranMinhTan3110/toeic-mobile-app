import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../../../data/models/vocabulary_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/tts_service.dart';

class FlipFlashcard extends StatelessWidget {
  final VocabularyModel vocabulary;
  final TtsService _ttsService = TtsService();

  FlipFlashcard({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT,
      speed: 400,
      front: _buildFrontSide(),
      back: _buildBackSide(),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              vocabulary.word,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              vocabulary.phonetic,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, size: 40),
              color: AppColors.primary,
              onPressed: () {
                _ttsService.speak(vocabulary.word);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Chạm để xem định nghĩa",
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header: Word + WordType
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  vocabulary.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                ),
                child: Text(
                  vocabulary.wordType.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: AppColors.divider, thickness: 1.5),
          ),

          // Meaning
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                "Định nghĩa",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            vocabulary.definitionVi,
            style: const TextStyle(fontSize: 22, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          
          if (vocabulary.examples.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: AppColors.divider, thickness: 1.5),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Ví dụ",
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\"${vocabulary.examples.first.sentence}\"",
                    style: const TextStyle(fontSize: 18, color: AppColors.textPrimary, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vocabulary.examples.first.sentenceVi,
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
