import 'package:flutter/foundation.dart';
import '../data/models/reading_part6_model.dart';
import '../data/repositories/reading_part6_repository.dart';
import '../data/repositories/user_repository.dart';
import 'user_provider.dart';

class ReadingPart6Provider with ChangeNotifier {
  final ReadingPart6Repository _repo = ReadingPart6Repository();

  UserProvider? _userProvider;
  void setUserProvider(UserProvider up) => _userProvider = up;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? _historyErrorMessage;
  String? get historyErrorMessage => _historyErrorMessage;

  List<ReadingPart6Question> _questions = [];
  List<ReadingPart6Question> get questions => _questions;

  List<ReadingPart6HistoryModel> _history = [];
  List<ReadingPart6HistoryModel> get history => _history;

  ReadingPart6SubmitResult? _lastSubmitResult;
  ReadingPart6SubmitResult? get lastSubmitResult => _lastSubmitResult;

  List<ReadingPart6Question>? _questionsCache;
  List<ReadingPart6Question>? get questionsCacheData => _questionsCache;

  int? _countCache;

  Future<void> fetchQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _questions = await _repo.getQuestions();
      _questionsCache = List<ReadingPart6Question>.from(_questions);
      _countCache = _questions.length;
      // ignore: avoid_print
      print(
        'ReadingPart6Provider.fetchQuestions: loaded ${_questions.length} questions',
      );
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
      debugPrint('Lỗi tải số câu Part 6: $e');
      return 0;
    }
  }

  /// Returns number of distinct passages available in the data source.
  Future<int> getPassageCount() async {
    try {
      if (_questionsCache == null) {
        await ensurePartLoaded();
      }
      final pool = _questionsCache ?? [];
      final keys = <String>{};
      for (var q in pool) {
        keys.add((q.passage ?? '').trim());
      }
      // debug
      // ignore: avoid_print
      print('ReadingPart6Provider.getPassageCount: passages=${keys.length}');
      return keys.length;
    } catch (e) {
      debugPrint('Lỗi getPassageCount Part6: $e');
      return 0;
    }
  }

  void preloadInBackground() {
    if (_questionsCache != null) return;
    _repo
        .getQuestions()
        .then((list) {
          _questionsCache = list;
          _countCache = list.length;
          notifyListeners();
        })
        .catchError((e) {
          debugPrint('[Preload Reading Part 6] $e');
        });
  }

  Future<void> ensurePartLoaded() async {
    try {
      if (_questionsCache != null) return;
      final list = await _repo.getQuestions();
      _questionsCache = list;
      _countCache = list.length;
      // debug
      // ignore: avoid_print
      print(
        'ReadingPart6Provider.ensurePartLoaded: questionsCache=${_questionsCache?.length}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[ensurePartLoaded Reading Part 6] $e');
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
      List<ReadingPart6Question> pool;
      if (_questionsCache != null) {
        pool = List<ReadingPart6Question>.from(_questionsCache!);
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

  /// New: fetch questions by number of passages.
  /// Groups cached questions by their `passage` text and selects [passageCount]
  /// passages (random order) then flattens their questions into `_questions`.
  Future<void> fetchQuestionsByPassageCount(int passageCount) async {
    final hasCachedData = _questionsCache != null;

    if (!hasCachedData) {
      _isLoading = true;
      _errorMessage = null;
      _questions = [];
      notifyListeners();
    }

    try {
      List<ReadingPart6Question> pool;
      if (_questionsCache != null) {
        pool = List<ReadingPart6Question>.from(_questionsCache!);
      } else {
        pool = await _repo.getQuestions();
        _questionsCache = pool;
        _countCache = pool.length;
      }

      // group by passage text
      final Map<String, List<ReadingPart6Question>> groups = {};
      for (var q in pool) {
        final key = (q.passage ?? '').trim();
        groups.putIfAbsent(key, () => []).add(q);
      }

      final keys = groups.keys.toList();
      keys.shuffle();
      final takeKeys = keys.take(passageCount.clamp(0, keys.length)).toList();

      final List<ReadingPart6Question> selected = [];
      for (var k in takeKeys) {
        selected.addAll(groups[k]!);
      }
      _questions = selected;
      // debug: print loaded questions and sample questionText
      // ignore: avoid_print
      print(
        'ReadingPart6Provider.fetchQuestionsByPassageCount: selected_questions=${_questions.length}',
      );
      if (_questions.isNotEmpty) {
        // ignore: avoid_print
        print(
          'ReadingPart6Provider.firstQuestion.questionText: ${_questions.first.questionText}',
        );
        // list details for debugging
        for (var i = 0; i < _questions.length && i < 20; i++) {
          final q = _questions[i];
          // ignore: avoid_print
          print(
            'ReadingPart6Provider.question[$i]: id=${q.id} questionText="${q.questionText}" prompt="${q.prompt}" options=${q.options.length}',
          );
        }
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReadingPart6SubmitResult> submitAnswers(
    Map<String, int?> answers,
  ) async {
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

      final newHistory = ReadingPart6HistoryModel(
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

      // Ghi nhận EP cho Reading và cập nhật UI ngay lập tức
      if (id.isNotEmpty && correctCount > 0) {
        try {
          final userRepository = UserRepository();
          final epResult = await userRepository.recordActivity(
            activityType: 'ReadingComplete',
            referenceId: id,
            correctAnswers: correctCount,
            totalAnswers: totalCount,
          );
          if (epResult != null) {
            _userProvider?.updateLocalEpAndStreak(epResult);
            // ignore: avoid_print
            print('✅ Reading P6 EP: +${epResult.epAwarded} EP');
          }
        } catch (epError) {
          // ignore: avoid_print
          print('Lỗi ghi nhận EP cho Reading P6: $epError');
        }
      }

      return id;
    } catch (e) {
      _errorMessage = 'Lỗi lưu lịch sử (server): $e';
      final newHistory = ReadingPart6HistoryModel(
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
