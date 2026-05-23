class KeywordItem {
  final String word;
  final String? ipa;
  final String meaning;

  const KeywordItem({
    required this.word,
    this.ipa,
    required this.meaning,
  });

  factory KeywordItem.fromJson(Map<String, dynamic> json) {
    return KeywordItem(
      word: json['word'] ?? '',
      ipa: json['ipa'],
      meaning: json['meaning'] ?? '',
    );
  }
}

class SpeakingExplanation {
  final String? translation;
  final List<KeywordItem> keywords;
  final List<String> questionsTranslation;
  final List<String> sampleAnswers;
  final List<String> sampleAnswersTranslation;

  const SpeakingExplanation({
    this.translation,
    this.keywords = const [],
    this.questionsTranslation = const [],
    this.sampleAnswers = const [],
    this.sampleAnswersTranslation = const [],
  });

  bool get hasSampleContent =>
      sampleAnswers.isNotEmpty || sampleAnswersTranslation.isNotEmpty;

  bool get hasTranslation =>
      (translation != null && translation!.trim().isNotEmpty) ||
      questionsTranslation.isNotEmpty;

  SpeakingExplanation mergeWith(SpeakingExplanation? other) {
    if (other == null) return this;
    return SpeakingExplanation(
      translation: (translation != null && translation!.trim().isNotEmpty)
          ? translation
          : other.translation,
      keywords: keywords.isNotEmpty ? keywords : other.keywords,
      questionsTranslation:
          questionsTranslation.isNotEmpty ? questionsTranslation : other.questionsTranslation,
      sampleAnswers: sampleAnswers.isNotEmpty ? sampleAnswers : other.sampleAnswers,
      sampleAnswersTranslation: sampleAnswersTranslation.isNotEmpty
          ? sampleAnswersTranslation
          : other.sampleAnswersTranslation,
    );
  }

  factory SpeakingExplanation.fromJson(Map<String, dynamic> json) {
    List<String> parseToList(List<String> keys) {
      dynamic value;
      for (var key in keys) {
        if (json[key] != null) {
          value = json[key];
          break;
        }
      }
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.trim().isNotEmpty) return [value];
      return [];
    }

    return SpeakingExplanation(
      translation: json['translation']?.toString(),
      keywords: (json['keywords'] as List?)
              ?.map((k) => KeywordItem.fromJson(k))
              .where((k) => k.word.isNotEmpty)
              .toList() ??
          const [],
      questionsTranslation: parseToList(['questions_translation', 'questionsTranslation']),
      sampleAnswers: parseToList(['sample_answers', 'sample_answer', 'sampleAnswers']),
      sampleAnswersTranslation: parseToList(['sample_answers_translation', 'sample_answer_translation', 'sampleAnswersTranslation']),
    );
  }
}

class SpeakingQuestion {
  final String id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final int prepSeconds;
  final int recordSeconds;
  final int taskNumber;
  final String? aiPrompt;
  final List<String> scoringCriteria;
  final List<String> questions;
  final List<int> answerTimes;
  final String? sampleAnswer;
  final SpeakingExplanation? explanation;

  const SpeakingQuestion({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.prepSeconds,
    required this.recordSeconds,
    required this.taskNumber,
    this.aiPrompt,
    this.scoringCriteria = const [],
    this.questions = const [],
    this.answerTimes = const [],
    this.sampleAnswer,
    this.explanation,
  });

  factory SpeakingQuestion.fromJson(Map<String, dynamic> json) {
    var qData = json['questions'] ?? [];
    List<String> qList = qData is List ? qData.map((e) => e.toString()).toList() : [];
    var tData = json['answer_times'] ?? json['answerTimes'] ?? [];
    List<int> tList = tData is List ? tData.map((e) => int.tryParse(e.toString()) ?? 0).toList() : [];

    final sampleAnswer = json['sample_answer'] ?? json['sampleAnswer'];
    final explanation = json['explanation'] != null
        ? SpeakingExplanation.fromJson(json['explanation'])
        : null;

    return SpeakingQuestion(
      id: json['id']?.toString() ?? '',
      text: json['prompt_text'] ?? json['promptText'] ?? '',
      imageUrl: json['prompt_image_url'] ?? json['promptImageUrl'] ?? json['image_url'],
      audioUrl: json['prompt_audio_url'] ?? json['promptAudioUrl'] ?? json['audio_url'],
      prepSeconds: (json['preparation_time'] ?? json['preparationTime'] ?? 0).toInt(),
      recordSeconds: (json['response_time'] ?? json['responseTime'] ?? 0).toInt(),
      taskNumber: (json['task_number'] ?? json['taskNumber'] ?? 0).toInt(),
      aiPrompt: json['ai_prompt'] ?? json['aiPrompt'],
      scoringCriteria: List<String>.from(json['scoring_criteria'] ?? json['scoringCriteria'] ?? []),
      questions: qList,
      answerTimes: tList,
      sampleAnswer: sampleAnswer?.toString(),
      explanation: explanation,
    ).withNormalizedExplanation();
  }

  /// Gộp sample_answer (top-level) vào explanation để panel giải thích luôn có dữ liệu.
  SpeakingQuestion withNormalizedExplanation() {
    final topSample = sampleAnswer?.trim();
    final base = explanation ?? const SpeakingExplanation();
    SpeakingExplanation? merged = base;

    if (topSample != null && topSample.isNotEmpty && base.sampleAnswers.isEmpty) {
      merged = SpeakingExplanation(
        translation: base.translation,
        keywords: base.keywords,
        questionsTranslation: base.questionsTranslation,
        sampleAnswers: [topSample],
        sampleAnswersTranslation: base.sampleAnswersTranslation,
      );
    }

    if (explanation != null && base.sampleAnswers.isNotEmpty) {
      return this;
    }
    if (topSample == null || topSample.isEmpty) {
      return this;
    }

    return SpeakingQuestion(
      id: id,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      prepSeconds: prepSeconds,
      recordSeconds: recordSeconds,
      taskNumber: taskNumber,
      aiPrompt: aiPrompt,
      scoringCriteria: scoringCriteria,
      questions: questions,
      answerTimes: answerTimes,
      sampleAnswer: sampleAnswer,
      explanation: merged,
    );
  }

  bool get hasExplanationContent =>
      explanation != null &&
      (explanation!.hasSampleContent || explanation!.hasTranslation || explanation!.keywords.isNotEmpty);

  SpeakingQuestion mergeExplanationFrom(SpeakingQuestion other) {
    if (hasExplanationContent) return this;
    if (!other.hasExplanationContent) return this;
    return SpeakingQuestion(
      id: id,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      prepSeconds: prepSeconds,
      recordSeconds: recordSeconds,
      taskNumber: taskNumber,
      aiPrompt: aiPrompt,
      scoringCriteria: scoringCriteria,
      questions: questions,
      answerTimes: answerTimes,
      sampleAnswer: sampleAnswer ?? other.sampleAnswer,
      explanation: (explanation ?? const SpeakingExplanation()).mergeWith(other.explanation),
    );
  }

  static bool matchesMock(SpeakingQuestion api, SpeakingQuestion mock) {
    if (api.id == mock.id || api.id.endsWith(mock.id)) return true;
    final a = api.text.trim().toLowerCase();
    final b = mock.text.trim().toLowerCase();
    if (a.isEmpty || b.isEmpty) return false;
    return a == b || a.startsWith(b.substring(0, b.length.clamp(0, 48)));
  }
}

class SpeakingQuestionData {
  static const Map<int, List<SpeakingQuestion>> byPart = {
    1: [
      SpeakingQuestion(
        id: 'mock_1',
        taskNumber: 1,
        prepSeconds: 45,
        recordSeconds: 45,
        text: 'The personnel managers have decided to make staff changes in the finance department. This is expected to be finalized by early next month.',
      ),
    ],
    2: [],
    3: [],
    4: [],
    5: [
      SpeakingQuestion(
        id: 'spk_task5_007',
        taskNumber: 5,
        prepSeconds: 15,
        recordSeconds: 60,
        text: 'What could be the most challenging part of working on a group project? Choose one of the options below and provide specific reasons or examples.\n- Adjusting to different work styles\n- Finding a way to resolve disagreements\n- Staying focused on the task',
        explanation: SpeakingExplanation(
          translation: 'Điều gì có thể là phần thách thức nhất khi làm việc trong một dự án nhóm? Hãy chọn một trong các phương án dưới đây và đưa ra lý do hoặc ví dụ cụ thể.',
          sampleAnswers: ['In my opinion, finding a way to resolve disagreements is the most challenging part of working on a group project. When people work together, they naturally bring different perspectives, experiences, and opinions to the table. If team members strongly protect their own ideas, serious conflicts can happen easily. For instance, during a university project last semester, my group members argued for days about which marketing strategy to choose. Because we did not know how to resolve our disagreements effectively, we wasted a lot of valuable time and missed our initial deadline.'],
          sampleAnswersTranslation: ['Theo ý kiến của tôi, việc tìm cách giải quyết những bất đồng ý kiến là phần thách thức nhất khi làm việc trong một dự án nhóm. Khi mọi người làm việc cùng nhau, họ sẽ mang đến những góc nhìn và kinh nghiệm khác nhau.'],
        ),
      ),
    ],
  };
}
