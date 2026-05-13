class ReadingPart7Question {
  final String id;
  final String prompt;
  final List<String> options;
  final String? explanation;

  ReadingPart7Question({required this.id, required this.prompt, required this.options, this.explanation});

  factory ReadingPart7Question.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final prompt = (json['questionText'] ?? json['question'] ?? json['prompt'] ?? '').toString();

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

    return ReadingPart7Question(id: id, prompt: prompt, options: options, explanation: json['explanation']);
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
    return ReadingPart7SubmitResult(correct: correct ?? 0, total: total ?? 0, details: details);
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
