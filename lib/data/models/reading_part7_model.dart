// Models for Reading Part 7

class ReadingPart7Question {
  final String id;
  final String passage;
  final String prompt;
  final List<String> options;
  final String? explanation;
  final String? explanationVi;
  final String? translation;
  final String? grammarExplanation;
  final String? grammarPoint;
  final Map<String, String>? optionExplanations;
  final String correctAnswer;

  ReadingPart7Question({
    required this.id,
    required this.passage,
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

  factory ReadingPart7Question.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final passage = (json['passage'] ?? json['script'] ?? json['context'] ?? json['paragraph'] ?? json['passageText'] ?? '').toString();
    final prompt = (json['questionText'] ?? json['question'] ?? json['prompt'] ?? json['stem'] ?? '').toString();

    List<String> options = [];
    if (json['options'] is List) {
      options = List<String>.from(json['options'] as List);
    } else {
      final a = json['optionA'] ?? json['A'] ?? json['a'];
      final b = json['optionB'] ?? json['B'] ?? json['b'];
      final c = json['optionC'] ?? json['C'] ?? json['c'];
      final d = json['optionD'] ?? json['D'] ?? json['d'];
      options = [a, b, c, d].where((e) => e != null).map((e) => e.toString()).toList();
    }

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
        explanation = (rawExp['en'] ?? rawExp['text'] ?? rawExp['explanation'] ?? rawExp['answer'])?.toString();
        explanationVi = (rawExp['vi'] ?? rawExp['vn'] ?? rawExp['vi_text'])?.toString();
        grammarExplanation = (rawExp['grammar'] ?? rawExp['grammar_explanation'] ?? rawExp['grammarExplanation'])?.toString();
        grammarPoint = (rawExp['grammarPoint'] ?? rawExp['grammar_point'] ?? rawExp['grammar'])?.toString();
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

    explanationVi ??= (json['explanationVi'] ?? json['explanation_vi'] ?? json['explain_vi'] ?? json['translation'] ?? json['translate'] ?? json['meaning'] ?? json['vi'])?.toString();
    translation ??= (json['translation'] ?? json['translate'] ?? json['translation_en'] ?? json['translate_en'])?.toString();
    grammarExplanation ??= (json['grammarExplanation'] ?? json['grammar_explanation'] ?? json['grammar'])?.toString();
    grammarPoint ??= (json['grammarPoint'] ?? json['grammar_point'] ?? json['grammar'])?.toString();

    if (optionExplanations == null) {
      final ro = json['optionExplanations'] ?? json['option_explanations'] ?? json['option_explain'];
      if (ro is Map) {
        optionExplanations = {};
        ro.forEach((k, v) {
          if (k != null && v != null) optionExplanations![k.toString()] = v.toString();
        });
      }
    }

    return ReadingPart7Question(
      id: id,
      passage: passage,
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

class QuestionResult7 {
  final String questionId;
  final String? selectedOption;
  final String? correctAnswer;
  final bool isCorrect;

  QuestionResult7({required this.questionId, this.selectedOption, this.correctAnswer, required this.isCorrect});

  factory QuestionResult7.fromJson(Map<String, dynamic> json) {
    return QuestionResult7(
      questionId: json['questionId']?.toString() ?? json['id']?.toString() ?? '',
      selectedOption: json['selectedOption'] ?? json['selected'] ?? json['selectedAnswer'],
      correctAnswer: json['correctAnswer'] ?? json['correct'] ?? json['answer'],
      isCorrect: json['isCorrect'] ?? json['corrected'] ?? false,
    );
  }
}

class ReadingPart7SubmitResult {
  final int correct;
  final int total;
  final List<QuestionResult7> details;

  ReadingPart7SubmitResult({required this.correct, required this.total, required this.details});

  factory ReadingPart7SubmitResult.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['results'] ?? json['details'] ?? json['items'] ?? [];
    final details = (detailsRaw as List).map((d) => QuestionResult7.fromJson(d as Map<String, dynamic>)).toList();
    final total = json['totalQuestions'] ?? json['total'] ?? 0;
    final correct = json['correctCount'] ?? json['correct'] ?? 0;
    return ReadingPart7SubmitResult(correct: (correct as num?)?.toInt() ?? 0, total: (total as num?)?.toInt() ?? 0, details: details);
  }
}

class ReadingPart7HistoryModel {
  final String id;
  final String userId;
  final int correctCount;
  final int totalCount;
  final double percent;
  final DateTime date;
  final List<String> incorrectQuestionIds;
  final Map<String, String> selectedAnswers;

  ReadingPart7HistoryModel({
    required this.id,
    required this.userId,
    required this.correctCount,
    required this.totalCount,
    required this.percent,
    required this.date,
    required this.incorrectQuestionIds,
    required this.selectedAnswers,
  });

  factory ReadingPart7HistoryModel.fromJson(Map<String, dynamic> json) {
    final rawIncorrect = json['incorrectQuestionIds'] ?? [];
    final incorrectQuestionIds = <String>[];
    if (rawIncorrect is List) {
      for (var e in rawIncorrect) {
        if (e == null) continue;
        incorrectQuestionIds.add(e.toString());
      }
    }

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
            selectedAnswers[k.toString()] = t;
          }
        } else {
          selectedAnswers[k.toString()] = v.toString();
        }
      });
    }

    return ReadingPart7HistoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now(),
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

class ReadingPart7Passage {
  final String id;
  final String passage;
  final List<ReadingPart7Question> questions;

  ReadingPart7Passage({required this.id, required this.passage, required this.questions});

  factory ReadingPart7Passage.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['passageId']?.toString() ?? '';
    final passage = (json['passageText'] ?? json['passage'] ?? json['text'] ?? '').toString();
    List<dynamic> qraw = [];
    if (json['questions'] is List) qraw = json['questions'];
    else if (json['items'] is List) qraw = json['items'];
    return ReadingPart7Passage(id: id, passage: passage, questions: qraw.map((e) => ReadingPart7Question.fromJson(e as Map<String, dynamic>)).toList());
  }
}
