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

  // ── In-Memory Cache ────────────────────────────────────────────────────────
  final Map<String, GrammarLesson> _lessonsCache = {};
  final Map<String, List<ListeningQuestion>> _exercisesCache = {};

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
  Future<void> fetchTopics({bool forceRefresh = false}) async {
    if (_topics.isNotEmpty && !forceRefresh) {
      debugPrint('ℹ️ [GrammarProvider] Grammar topics already loaded. Using cache.');
      return;
    }

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
  Future<void> fetchLesson(String topicId, {bool forceRefresh = false}) async {
    if (_lessonsCache.containsKey(topicId) && !forceRefresh) {
      _currentLesson = _lessonsCache[topicId];
      _lessonError = null;
      debugPrint('ℹ️ [GrammarProvider] Lesson for topic "$topicId" already loaded. Using cache.');
      notifyListeners();
      return;
    }

    _isLoadingLesson = true;
    _lessonError = null;
    _currentLesson = null; // Clear previous lesson
    notifyListeners();

    try {
      final lesson = await _repository.getGrammarLesson(topicId);
      _currentLesson = lesson;
      _lessonsCache[topicId] = lesson;
    } catch (e) {
      _lessonError = e.toString();
      debugPrint('Error fetching grammar lesson: $e');
    } finally {
      _isLoadingLesson = false;
      notifyListeners();
    }
  }

  /// Tải danh sách câu hỏi luyện tập (10 câu)
  Future<void> fetchExercises(String topicId, {bool forceRefresh = false}) async {
    if (_exercisesCache.containsKey(topicId) && !forceRefresh) {
      _exercises = _exercisesCache[topicId]!;
      _exercisesError = null;
      debugPrint('ℹ️ [GrammarProvider] Exercises for topic "$topicId" already loaded. Using cache.');
      notifyListeners();
      return;
    }

    _isLoadingExercises = true;
    _exercisesError = null;
    _exercises = []; // Clear previous exercises
    notifyListeners();

    try {
      _exercises = await _repository.getGrammarExercises(topicId);
      _exercisesCache[topicId] = _exercises;
    } catch (e) {
      _exercisesError = e.toString();
      debugPrint('Error fetching grammar exercises: $e');
    } finally {
      _isLoadingExercises = false;
      notifyListeners();
    }
  }

  /// Xóa cache khi cần thiết (ví dụ khi user đăng xuất)
  void clearCache() {
    _topics.clear();
    _lessonsCache.clear();
    _exercisesCache.clear();
  }
}
