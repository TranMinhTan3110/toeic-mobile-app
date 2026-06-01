class ReadingPart6Question {
  final String id;
  final String prompt;
  final List<String> options;
  final String? explanation;

  ReadingPart6Question({required this.id, required this.prompt, required this.options, this.explanation});

  factory ReadingPart6Question.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
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

    return ReadingPart6Question(id: id, prompt: prompt, options: options, explanation: json['explanation']);
  }
}

class ReadingPart6Passage {
  final String id;
  final String passage;
  final List<ReadingPart6Question> questions;

  ReadingPart6Passage({required this.id, required this.passage, required this.questions});

  factory ReadingPart6Passage.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['passageId']?.toString() ?? '';
    final passage = (json['passageText'] ?? json['passage'] ?? json['text'] ?? '').toString();
    List<dynamic> qraw = [];
    if (json['questions'] is List) qraw = json['questions'];
    else if (json['items'] is List) qraw = json['items'];
    return ReadingPart6Passage(id: id, passage: passage, questions: qraw.map((e) => ReadingPart6Question.fromJson(e as Map<String, dynamic>)).toList());
  }
}

class ReadingPart6SubmitResult {
  final int correct;
  final int total;
  final List<QuestionResult6> details;

  ReadingPart6SubmitResult({required this.correct, required this.total, required this.details});

  factory ReadingPart6SubmitResult.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['results'] ?? json['details'] ?? json['items'] ?? [];
    final details = (detailsRaw as List).map((d) => QuestionResult6.fromJson(d as Map<String, dynamic>)).toList();
    final total = json['totalQuestions'] ?? json['total'] ?? 0;
    final correct = json['correctCount'] ?? json['correct'] ?? 0;
    return ReadingPart6SubmitResult(correct: correct ?? 0, total: total ?? 0, details: details);
  }
}

class QuestionResult6 {
  final String questionId;
  final String? selectedOption;
  final String? correctAnswer;
  final bool isCorrect;

  QuestionResult6({required this.questionId, this.selectedOption, this.correctAnswer, required this.isCorrect});

  factory QuestionResult6.fromJson(Map<String, dynamic> json) {
    return QuestionResult6(
      questionId: json['questionId']?.toString() ?? json['id']?.toString() ?? '',
      selectedOption: json['selectedOption'] ?? json['selected'] ?? json['selectedAnswer'],
      correctAnswer: json['correctAnswer'] ?? json['correct'] ?? json['answer'],
      isCorrect: json['isCorrect'] ?? json['corrected'] ?? false,
    );
  }
}
