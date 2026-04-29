class VocabularyModel {
  final String id;
  final String word;
  final String phonetic;
  final String wordType;
  final String definitionEn;
  final String definitionVi;
  final List<ExampleModel> examples;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> collocations; // Thêm cụm từ
  final String? audioUrl;
  final String? imageUrl;
  final bool isStarred;

  VocabularyModel({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.wordType,
    required this.definitionEn,
    required this.definitionVi,
    this.examples = const [],
    this.synonyms = const [],
    this.antonyms = const [],
    this.collocations = const [],
    this.audioUrl,
    this.imageUrl,
    this.isStarred = false,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      phonetic: json['phonetic'] ?? '',
      wordType: json['wordType'] ?? '',
      definitionEn: json['definitionEn'] ?? '',
      definitionVi: json['definitionVi'] ?? '',
      examples: (json['examples'] as List? ?? [])
          .map((e) => ExampleModel.fromJson(e))
          .toList(),
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
      collocations: List<String>.from(json['collocations'] ?? []),
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
    );
  }

  VocabularyModel copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? wordType,
    String? definitionEn,
    String? definitionVi,
    List<ExampleModel>? examples,
    List<String>? synonyms,
    List<String>? antonyms,
    List<String>? collocations,
    String? audioUrl,
    String? imageUrl,
    bool? isStarred,
  }) {
    return VocabularyModel(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      wordType: wordType ?? this.wordType,
      definitionEn: definitionEn ?? this.definitionEn,
      definitionVi: definitionVi ?? this.definitionVi,
      examples: examples ?? this.examples,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      collocations: collocations ?? this.collocations,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}

class ExampleModel {
  final String sentence;
  final String sentenceVi;

  ExampleModel({
    required this.sentence,
    required this.sentenceVi,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      sentence: json['sentence'] ?? '',
      sentenceVi: json['sentenceVi'] ?? '',
    );
  }
}
