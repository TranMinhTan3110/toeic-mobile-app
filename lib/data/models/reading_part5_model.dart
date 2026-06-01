class ReadingPart5Question {
  final String id;
  final String prompt;
  final List<String> options;
  final String? explanation;

  ReadingPart5Question({
    required this.id,
    required this.prompt,
    required this.options,
    this.explanation,
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

    return ReadingPart5Question(
      id: id,
      prompt: prompt,
      options: options,
      explanation: json['explanation'],
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
