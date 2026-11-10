import 'listening_data.dart';

class ReadingPart5Question {
  final String id;
  final String prompt;
  final List<String> options;
  final String? explanation;
  final String? explanationVi;
  final String? translation;
  final String? grammarExplanation;
  final String? grammarPoint;
  final Map<String, String>? optionExplanations;
  final String correctAnswer;

  ReadingPart5Question({
    required this.id,
    required this.prompt,
    required this.options,
    this.explanation,
    this.explanationVi,
    this.translation,
    this.grammarExplanation,
    this.grammarPoint,
    this.optionExplanations,
    this.correctAnswer = '',
  });

  factory ReadingPart5Question.fromJson(Map<String, dynamic> json) {
    // Support multiple API shapes: { questionText, optionA..D } or { prompt, options: [] }
    final id = json['id']?.toString() ?? '';
    final prompt = (json['questionText'] ?? json['question'] ?? json['prompt'] ?? '').toString();

    List<String> options = [];
    if (json['options'] is List) {
      options = List<String>.from(json['options']!);
    } else {
      // attempt to collect optionA..optionD
      final a = json['optionA'] ?? json['A'] ?? json['a'];
      final b = json['optionB'] ?? json['B'] ?? json['b'];
      final c = json['optionC'] ?? json['C'] ?? json['c'];
      final d = json['optionD'] ?? json['D'] ?? json['d'];
      options = [a, b, c, d].where((e) => e != null).map((e) => e.toString()).toList();
    }

    // Normalize correct answer from various possible keys
    String correctAnswer = '';
    final caCandidates = [
      json['correctAnswer'],
      json['correct_answer'],
      json['correct'],
      json['answer'],
      json['answer_key'],
      json['key'],
    ];
    for (var c in caCandidates) {
      if (c != null) {
        correctAnswer = c.toString();
        break;
      }
    }

    // Normalize explanation which may be a string or a map {en:..., vi:...}
    String? explanation;
    String? explanationVi;
    String? translation;
    String? grammarExplanation;
    String? grammarPoint;
    Map<String, String>? optionExplanations;
    final rawExp = json['explanation'] ?? json['explain'] ?? json['solution'] ?? json['answerExplanation'];
    if (rawExp != null) {
      if (rawExp is String) {
        explanation = rawExp;
      } else if (rawExp is Map) {
        // try common keys
        explanation = (rawExp['en'] ?? rawExp['text'] ?? rawExp['explanation'] ?? rawExp['answer'])?.toString();
        explanationVi = (rawExp['vi'] ?? rawExp['vn'] ?? rawExp['vi_text'])?.toString();
        // grammar explanation could be nested
        grammarExplanation = (rawExp['grammar'] ?? rawExp['grammar_explanation'] ?? rawExp['grammarExplanation'])?.toString();
        grammarPoint = (rawExp['grammarPoint'] ?? rawExp['grammar_point'] ?? rawExp['grammar'])?.toString();
        // option explanations may live under optionExplanations or option_explanations
        final rawOptExp = rawExp['optionExplanations'] ?? rawExp['option_explanations'] ?? rawExp['option_explain'];
        if (rawOptExp is Map) {
          optionExplanations = {};
          rawOptExp.forEach((k, v) {
            if (k != null && v != null) optionExplanations![k.toString()] = v.toString();
          });
        }
      } else {
        explanation = rawExp.toString();
      }
    }

    // translation / explanation_vi / grammar fallback
    explanationVi ??= (json['explanationVi'] ?? json['explanation_vi'] ?? json['explain_vi'] ?? json['translation'] ?? json['translate'] ?? json['meaning'] ?? json['vi'])?.toString();
    translation ??= (json['translation'] ?? json['translate'] ?? json['translation_en'] ?? json['translate_en'])?.toString();
    grammarExplanation ??= (json['grammarExplanation'] ?? json['grammar_explanation'] ?? json['grammar'])?.toString();
    grammarPoint ??= (json['grammarPoint'] ?? json['grammar_point'] ?? json['grammar'])?.toString();
    // top-level option explanations
    if (optionExplanations == null) {
      final ro = json['optionExplanations'] ?? json['option_explanations'] ?? json['option_explain'];
      if (ro is Map) {
        optionExplanations = {};
        ro.forEach((k, v) {
          if (k != null && v != null) optionExplanations![k.toString()] = v.toString();
        });
      }
    }

    return ReadingPart5Question(
      id: id,
      prompt: prompt,
      options: options,
      explanation: explanation,
      explanationVi: explanationVi,
      translation: translation,
      grammarExplanation: grammarExplanation,
      grammarPoint: grammarPoint,
      optionExplanations: optionExplanations,
      correctAnswer: correctAnswer,
    );
  }
}

class ReadingPart5SubmitResult {
  final int correct;
  final int total;
  final List<QuestionResult> details;

  ReadingPart5SubmitResult({required this.correct, required this.total, required this.details});

  factory ReadingPart5SubmitResult.fromJson(Map<String, dynamic> json) {
    // Support API shape: { totalQuestions, correctCount, results: [...] }
    final detailsRaw = json['results'] ?? json['details'] ?? json['items'] ?? [];
    final details = (detailsRaw as List).map((d) => QuestionResult.fromJson(d as Map<String, dynamic>)).toList();
    final total = json['totalQuestions'] ?? json['total'] ?? 0;
    final correct = json['correctCount'] ?? json['correct'] ?? 0;
    return ReadingPart5SubmitResult(
      correct: correct ?? 0,
      total: total ?? 0,
      details: details,
    );
  }
}

class QuestionResult {
  final String questionId;
  final String? selectedOption; // e.g. 'A'
  final String? correctAnswer; // e.g. 'A'
  final bool isCorrect;

  QuestionResult({required this.questionId, this.selectedOption, this.correctAnswer, required this.isCorrect});

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId']?.toString() ?? json['id']?.toString() ?? '',
      selectedOption: json['selectedOption'] ?? json['selected'] ?? json['selectedAnswer'],
      correctAnswer: json['correctAnswer'] ?? json['correct'] ?? json['answer'],
      isCorrect: json['isCorrect'] ?? json['corrected'] ?? false,
    );
  }
}

class ReadingPart5HistoryModel {
  final String id;
  final String userId;
  final int correctCount;
  final int totalCount;
  final double percent;
  final DateTime date;
  final List<String> incorrectQuestionIds;
  final Map<String, String> selectedAnswers;

  ReadingPart5HistoryModel({
    required this.id,
    required this.userId,
    required this.correctCount,
    required this.totalCount,
    required this.percent,
    required this.date,
    required this.incorrectQuestionIds,
    required this.selectedAnswers,
  });

  factory ReadingPart5HistoryModel.fromJson(Map<String, dynamic> json) {
    // Normalize incorrectQuestionIds to list of strings
    final rawIncorrect = json['incorrectQuestionIds'] ?? [];
    final incorrectQuestionIds = <String>[];
    if (rawIncorrect is List) {
      for (var e in rawIncorrect) {
        if (e == null) continue;
        incorrectQuestionIds.add(e.toString());
      }
    }

    // Normalize selectedAnswers: support shapes where values are indices (0/1) or letters or full text
    final rawSelected = json['selectedAnswers'] ?? {};
    final Map<String, String> selectedAnswers = {};
    if (rawSelected is Map) {
      rawSelected.forEach((k, v) {
        if (k == null) return;
        if (v == null) return;
        final val = v;
        final letters = ['A', 'B', 'C', 'D'];
        if (val is num) {
          final idx = val.toInt();
          if (idx >= 0 && idx < letters.length) selectedAnswers[k.toString()] = letters[idx];
          else selectedAnswers[k.toString()] = val.toString();
        } else if (val is String) {
          final t = val.trim();
          final asInt = int.tryParse(t);
          if (asInt != null && asInt >= 0 && asInt < letters.length) {
            selectedAnswers[k.toString()] = letters[asInt];
          } else if (t.length == 1 && 'ABCD'.contains(t.toUpperCase())) {
            selectedAnswers[k.toString()] = t.toUpperCase();
          } else {
            // fallback: store raw string (could be full option text)
            selectedAnswers[k.toString()] = t;
          }
        } else {
          selectedAnswers[k.toString()] = v.toString();
        }
      });
    }

    return ReadingPart5HistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      correctCount: json['correctCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      incorrectQuestionIds: incorrectQuestionIds,
      selectedAnswers: selectedAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'percent': percent,
      'date': date.toIso8601String(),
      'incorrectQuestionIds': incorrectQuestionIds,
      'selectedAnswers': selectedAnswers,
    };
  }
}

// Extension to convert to HistoryItem for PartHistorySheet
extension ReadingPart5HistoryModelX on ReadingPart5HistoryModel {
  HistoryItem toHistoryItem() {
    return HistoryItem(
      title: 'Reading Part 5 - ${date.day}/${date.month}/${date.year}',
      percent: percent,
      correct: correctCount,
      total: totalCount,
      date: date,
    );
  }
}

extension ReadingPart5HistoryListX on List<ReadingPart5HistoryModel> {
  List<HistoryItem> toHistoryItems() => map((h) => h.toHistoryItem()).toList();
}
