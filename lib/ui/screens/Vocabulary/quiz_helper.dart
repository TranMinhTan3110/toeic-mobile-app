import 'dart:math';
import '../../../data/models/vocabulary_model.dart';
import '../../widgets/practice/answer_card.dart';

enum QuizType {
  wordToDefinition, // Chọn nghĩa của từ
  definitionToWord  // Chọn từ của nghĩa
}

class QuizQuestion {
  final String question;
  final List<AnswerOption> options;
  final String correctKey;
  final VocabularyModel originalWord;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctKey,
    required this.originalWord,
  });
}

class QuizHelper {
  static List<QuizQuestion> generateQuiz(List<VocabularyModel> words, QuizType type) {
    if (words.length < 4) return []; // Không đủ từ để tạo distractors

    final List<QuizQuestion> questions = [];
    final random = Random();
    
    // Xáo trộn danh sách từ vựng
    final shuffledWords = List<VocabularyModel>.from(words)..shuffle(random);

    for (var word in shuffledWords) {
      final List<String> distractors = [];
      final List<VocabularyModel> potentialDistractors = words.where((w) => w.id != word.id).toList();
      potentialDistractors.shuffle(random);

      for (int i = 0; i < 3; i++) {
        if (type == QuizType.wordToDefinition) {
          distractors.add(potentialDistractors[i].definitionVi);
        } else {
          distractors.add(potentialDistractors[i].word);
        }
      }

      final correctText = type == QuizType.wordToDefinition ? word.definitionVi : word.word;
      final allOptionsText = [correctText, ...distractors]..shuffle(random);
      
      final options = <AnswerOption>[];
      String? correctKey;
      
      final keys = ['A', 'B', 'C', 'D'];
      for (int i = 0; i < 4; i++) {
        options.add(AnswerOption(key: keys[i], text: allOptionsText[i]));
        if (allOptionsText[i] == correctText) {
          correctKey = keys[i];
        }
      }

      questions.add(QuizQuestion(
        question: type == QuizType.wordToDefinition ? word.word : word.definitionVi,
        options: options,
        correctKey: correctKey!,
        originalWord: word,
      ));
    }

    return questions;
  }
}
