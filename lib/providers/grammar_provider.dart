import 'package:flutter/foundation.dart';
import '../data/models/grammar_model.dart';
import '../data/models/listening_question.dart';
import '../data/repositories/grammar_repository.dart';

class GrammarProvider with ChangeNotifier {
  final GrammarRepository _repository = GrammarRepository();

  List<GrammarTopic> _topics = [];
  List<GrammarTopic> get topics => _topics;

  GrammarLesson? _currentLesson;
  GrammarLesson? get currentLesson => _currentLesson;

  List<ListeningQuestion> _exercises = [];
  List<ListeningQuestion> get exercises => _exercises;

  // ── States ──────────────────────────────────────────────────────────────────
  bool _isLoadingTopics = false;
  bool get isLoadingTopics => _isLoadingTopics;

  bool _isLoadingLesson = false;
  bool get isLoadingLesson => _isLoadingLesson;

  bool _isLoadingExercises = false;
  bool get isLoadingExercises => _isLoadingExercises;

  String? _topicsError;
  String? get topicsError => _topicsError;

  String? _lessonError;
  String? get lessonError => _lessonError;

  String? _exercisesError;
  String? get exercisesError => _exercisesError;

  // ── Actions ─────────────────────────────────────────────────────────────────

  /// Tải danh sách các chủ đề ngữ pháp
  Future<void> fetchTopics() async {
    _isLoadingTopics = true;
    _topicsError = null;
    notifyListeners();

    try {
      _topics = await _repository.getGrammarTopics();
    } catch (e) {
      _topicsError = e.toString();
      debugPrint('Error fetching grammar topics: $e');
    } finally {
      _isLoadingTopics = false;
      notifyListeners();
    }
  }

  /// Tải nội dung bài học lý thuyết
  Future<void> fetchLesson(String topicId) async {
    _isLoadingLesson = true;
    _lessonError = null;
    _currentLesson = null; // Clear previous lesson
    notifyListeners();

    try {
      _currentLesson = await _repository.getGrammarLesson(topicId);
    } catch (e) {
      _lessonError = e.toString();
      debugPrint('Error fetching grammar lesson: $e');
    } finally {
      _isLoadingLesson = false;
      notifyListeners();
    }
  }

  /// Tải danh sách câu hỏi luyện tập (10 câu)
  Future<void> fetchExercises(String topicId) async {
    _isLoadingExercises = true;
    _exercisesError = null;
    _exercises = []; // Clear previous exercises
    notifyListeners();

    try {
      _exercises = await _repository.getGrammarExercises(topicId);
    } catch (e) {
      _exercisesError = e.toString();
      debugPrint('Error fetching grammar exercises: $e');
    } finally {
      _isLoadingExercises = false;
      notifyListeners();
    }
  }
}
