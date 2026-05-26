class GrammarTopic {
  final String id;
  final String title;
  final String titleEn;
  final String category;
  final String description;
  final String icon;
  final int lessonCount;
  final int exerciseCount;
  final List<int> relatedParts;
  final String difficulty;
  final int order;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.category,
    required this.description,
    required this.icon,
    required this.lessonCount,
    required this.exerciseCount,
    required this.relatedParts,
    required this.difficulty,
    required this.order,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleEn: json['titleEn'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      lessonCount: json['lessonCount'] ?? 0,
      exerciseCount: json['exerciseCount'] ?? 0,
      relatedParts: List<int>.from(json['relatedParts'] ?? []),
      difficulty: json['difficulty'] ?? 'basic',
      order: json['order'] ?? 0,
    );
  }
}

class GrammarLesson {
  final String id;
  final String topicId;
  final String title;
  final String content;
  final int order;

  GrammarLesson({
    required this.id,
    required this.topicId,
    required this.title,
    required this.content,
    required this.order,
  });

  factory GrammarLesson.fromJson(Map<String, dynamic> json) {
    return GrammarLesson(
      id: json['id'] ?? '',
      topicId: json['topicId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}
