import 'package:flutter/foundation.dart';
import '../data/models/reading_part7_model.dart';
import '../data/repositories/reading_part7_repository.dart';

class ReadingPart7Provider with ChangeNotifier {
  final ReadingPart7Repository _repo = ReadingPart7Repository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? _historyErrorMessage;
  String? get historyErrorMessage => _historyErrorMessage;

  List<ReadingPart7Question> _questions = [];
  List<ReadingPart7Question> get questions => _questions;

  List<ReadingPart7HistoryModel> _history = [];
  List<ReadingPart7HistoryModel> get history => _history;

  ReadingPart7SubmitResult? _lastSubmitResult;
  ReadingPart7SubmitResult? get lastSubmitResult => _lastSubmitResult;

  List<ReadingPart7Question>? _questionsCache;
  List<ReadingPart7Question>? get questionsCacheData => _questionsCache;

  int? _countCache;

  Future<void> fetchQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _questions = await _repo.getQuestions();
      _questionsCache = List<ReadingPart7Question>.from(_questions);
      _countCache = _questions.length;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getCountByPart() async {
    if (_countCache != null) return _countCache!;
    try {
      final count = await _repo.getCountByPart();
      _countCache = count;
      return count;
    } catch (e) {
      debugPrint('Lỗi tải số câu Part 7: $e');
      return 0;
    }
  }

  void preloadInBackground() {
    if (_questionsCache != null) return;
    _repo.getQuestions().then((list) {
      _questionsCache = list;
      _countCache = list.length;
      notifyListeners();
    }).catchError((e) {
      debugPrint('[Preload Reading Part 7] $e');
    });
  }

  Future<void> ensurePartLoaded() async {
    try {
      if (_questionsCache != null) return;
      final list = await _repo.getQuestions();
      _questionsCache = list;
      _countCache = list.length;
      notifyListeners();
    } catch (e) {
      debugPrint('[ensurePartLoaded Reading Part 7] $e');
      rethrow;
    }
  }

  Future<void> fetchQuestionsByCount(int requestedCount) async {
    final hasCachedData = _questionsCache != null;

    if (!hasCachedData) {
      _isLoading = true;
      _errorMessage = null;
      _questions = [];
      notifyListeners();
    }

    try {
      List<ReadingPart7Question> pool;
      if (_questionsCache != null) {
        pool = List<ReadingPart7Question>.from(_questionsCache!);
      } else {
        pool = await _repo.getQuestions();
        _questionsCache = pool;
        _countCache = pool.length;
      }
      pool.shuffle();
      _questions = pool.take(requestedCount).toList();
    } catch (e) {
      _errorMessage = 'Lỗi kết nối API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReadingPart7SubmitResult> submitAnswers(Map<String, int?> answers) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repo.submitAnswers(answers);
      _lastSubmitResult = res;
      return res;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    _isHistoryLoading = true;
    _historyErrorMessage = null;
    notifyListeners();

    try {
      _history = await _repo.getHistory();
    } catch (e) {
      _historyErrorMessage = 'Lỗi tải lịch sử: $e';
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<String> savePracticeHistory({
    required int correctCount,
    required int totalCount,
    required double percent,
    required List<String> incorrectQuestionIds,
    required Map<String, String> selectedAnswers,
  }) async {
    try {
      final id = await _repo.saveHistory(
        correctCount: correctCount,
        totalCount: totalCount,
        percent: percent,
        incorrectQuestionIds: incorrectQuestionIds,
        selectedAnswers: selectedAnswers,
      );

      final newHistory = ReadingPart7HistoryModel(
        id: id,
        userId: '',
        correctCount: correctCount,
        totalCount: totalCount,
        percent: percent,
        date: DateTime.now(),
        incorrectQuestionIds: incorrectQuestionIds,
        selectedAnswers: selectedAnswers,
      );

      _history.insert(0, newHistory);
      notifyListeners();

      return id;
    } catch (e) {
      _errorMessage = 'Lỗi lưu lịch sử (server): $e';
      final newHistory = ReadingPart7HistoryModel(
        id: '',
        userId: '',
        correctCount: correctCount,
        totalCount: totalCount,
        percent: percent,
        date: DateTime.now(),
        incorrectQuestionIds: incorrectQuestionIds,
        selectedAnswers: selectedAnswers,
      );

      _history.insert(0, newHistory);
      notifyListeners();
      return '';
    }
  }

  void clearCache() {
    _questionsCache = null;
    _countCache = null;
  }
}
*** End Patch
