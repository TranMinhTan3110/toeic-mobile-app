import 'package:flutter/foundation.dart';
import '../data/models/reading_part5_model.dart';
import '../data/repositories/reading_part5_repository.dart';
import '../data/repositories/user_repository.dart';
import 'user_provider.dart';

class ReadingPart5Provider with ChangeNotifier {
  final ReadingPart5Repository _repo = ReadingPart5Repository();

  UserProvider? _userProvider;
  void setUserProvider(UserProvider up) => _userProvider = up;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  // Separate error for history loading so it doesn't override question errors
  String? _historyErrorMessage;
  String? get historyErrorMessage => _historyErrorMessage;

  List<ReadingPart5Question> _questions = [];
  List<ReadingPart5Question> get questions => _questions;

  List<ReadingPart5HistoryModel> _history = [];
  List<ReadingPart5HistoryModel> get history => _history;

  ReadingPart5SubmitResult? _lastSubmitResult;
  ReadingPart5SubmitResult? get lastSubmitResult => _lastSubmitResult;

  /// Cache toàn bộ câu hỏi Reading Part 5
  List<ReadingPart5Question>? _questionsCache;
  List<ReadingPart5Question>? get questionsCacheData => _questionsCache;

  /// Cache số câu
  int? _countCache;

  Future<void> fetchQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _questions = await _repo.getQuestions();
      _questionsCache = List<ReadingPart5Question>.from(_questions);
      _countCache = _questions.length;
      // debug
      // ignore: avoid_print
      print(
        'ReadingPart5Provider.fetchQuestions: loaded ${_questions.length} questions',
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy số câu (từ API count endpoint)
  Future<int> getCountByPart() async {
    if (_countCache != null) {
      return _countCache!;
    }
    try {
      final count = await _repo.getCountByPart();
      _countCache = count;
      return count;
    } catch (e) {
      debugPrint('Lỗi tải số câu Part 5: $e');
      return 0;
    }
  }

  /// Preload data ở background
  void preloadInBackground() {
    if (_questionsCache != null) return; // Đã có rồi
    _repo
        .getQuestions()
        .then((list) {
          _questionsCache = list;
          _countCache = list.length;
          notifyListeners();
        })
        .catchError((e) {
          debugPrint('[Preload Reading Part 5] $e');
        });
  }

  /// Đảm bảo dữ liệu được tải vào cache
  Future<void> ensurePartLoaded() async {
    try {
      if (_questionsCache != null) return;
      final list = await _repo.getQuestions();
      _questionsCache = list;
      _countCache = list.length;
      notifyListeners();
    } catch (e) {
      debugPrint('[ensurePartLoaded Reading Part 5] $e');
      rethrow;
    }
  }

  /// Load câu hỏi với số lượng yêu cầu
  Future<void> fetchQuestionsByCount(int requestedCount) async {
    final hasCachedData = _questionsCache != null;

    if (!hasCachedData) {
      _isLoading = true;
      _errorMessage = null;
      _questions = [];
      notifyListeners();
    }

    try {
      List<ReadingPart5Question> pool;
      if (_questionsCache != null) {
        pool = List<ReadingPart5Question>.from(_questionsCache!);
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

  Future<ReadingPart5SubmitResult> submitAnswers(
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

  /// Lấy lịch sử luyện tập
  Future<void> fetchHistory() async {
    _isHistoryLoading = true;
    _historyErrorMessage = null;
    notifyListeners();

    try {
      _history = await _repo.getHistory();
      // ignore: avoid_print
      print(
        'ReadingPart5Provider.fetchHistory: loaded ${_history.length} items',
      );
    } catch (e) {
      _historyErrorMessage = 'Lỗi tải lịch sử: $e';
      // ignore: avoid_print
      print('ReadingPart5Provider.fetchHistory error: $e');
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  /// Lưu lịch sử luyện tập
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

      // ignore: avoid_print
      print('ReadingPart5Provider.savePracticeHistory: saved with id=$id');

      // Thêm vào danh sách lịch sử local
      final newHistory = ReadingPart5HistoryModel(
        id: id,
        userId: '', // Will be fetched from API
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
            print('✅ Reading P5 EP: +${epResult.epAwarded} EP');
          }
        } catch (epError) {
          // ignore: avoid_print
          print('Lỗi ghi nhận EP cho Reading P5: $epError');
        }
      }

      // ignore: avoid_print
      print(
        'ReadingPart5Provider.savePracticeHistory: local history now has ${_history.length} items',
      );

      return id;
    } catch (e) {
      // If saving to backend fails, still keep a local history record so UX reflects user's session.
      _errorMessage = 'Lỗi lưu lịch sử (server): $e';
      // ignore: avoid_print
      print('ReadingPart5Provider.savePracticeHistory error: $e');

      final newHistory = ReadingPart5HistoryModel(
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

  /// Xóa cache
  void clearCache() {
    _questionsCache = null;
    _countCache = null;
  }
}
