import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/writing_history_item.dart';
import '../data/repositories/writing_repository.dart';
import '../data/models/writing_evaluation_model.dart';
import '../data/repositories/user_repository.dart';
import 'user_provider.dart';

class WritingProvider with ChangeNotifier {
  final WritingRepository _repository = WritingRepository();

  /// Tham chiếu đến UserProvider để cập nhật EP ngay lập tức sau khi làm bài
  UserProvider? _userProvider;
  void setUserProvider(UserProvider up) => _userProvider = up;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  bool _isEvaluating = false;
  bool get isEvaluating => _isEvaluating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<WritingHistoryItem> _historyItems = [];
  List<WritingHistoryItem> get historyItems => _historyItems;

  WritingHistoryItem? _selectedSubmission;
  WritingHistoryItem? get selectedSubmission => _selectedSubmission;

  WritingEvaluation? _lastEvaluation;
  WritingEvaluation? get lastEvaluation => _lastEvaluation;

  Future<void> fetchHistory({
    bool forceRefresh = false,
    String? sessionType,
  }) async {
    if (!forceRefresh && _historyItems.isNotEmpty) return;

    _isHistoryLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historyItems = await _repository.getHistory(sessionType: sessionType);
      if (_historyItems.isEmpty) {
        _errorMessage = null;
      }
    } catch (e) {
      _historyItems = [];
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final serverMessage = e.response?.data?.toString();
        _errorMessage =
            'Không tải được lịch sử Writing.'
            '${statusCode != null ? ' ($statusCode)' : ''}';
        if (serverMessage != null && serverMessage.isNotEmpty) {
          _errorMessage = '${_errorMessage ?? ''}\n$serverMessage';
        }
      } else {
        _errorMessage = 'Không tải được lịch sử Writing. Vui lòng thử lại.';
      }
      debugPrint('Error fetching writing history: $e');
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<WritingHistoryItem?> fetchHistoryDetail(String id) async {
    try {
      _selectedSubmission = await _repository.getHistoryById(id);
      notifyListeners();
      return _selectedSubmission;
    } catch (e) {
      debugPrint('Error fetching writing history detail: $e');
      return null;
    }
  }

  Future<String?> saveSubmission({
    required String questionId,
    required String userAnswer,
    String sessionType = 'practice',
    int? taskNumber,
    String? taskType,
    int? wordCount,
    int? timeUsed,
    int? aiScore,
    WritingAiFeedback? aiFeedback,
  }) async {
    _errorMessage = null;
    try {
      final id = await _repository.saveSubmission(
        questionId: questionId,
        sessionType: sessionType,
        userAnswer: userAnswer,
        taskNumber: taskNumber,
        taskType: taskType,
        wordCount: wordCount,
        timeUsed: timeUsed,
        aiScore: aiScore,
        aiFeedback: aiFeedback,
      );
      await fetchHistory(forceRefresh: true);

      // Ghi nhận EP cho Writing submission và cập nhật UI ngay lập tức
      if (id != null && sessionType == 'practice' && aiScore != null && aiScore > 0) {
        try {
          final userRepository = UserRepository();
          final epResult = await userRepository.recordActivity(
            activityType: 'WritingComplete',
            referenceId: id,
            correctAnswers: aiScore,
            totalAnswers: 10,
          );
          if (epResult != null) {
            _userProvider?.updateLocalEpAndStreak(epResult);
            debugPrint('✅ Writing EP: +${epResult.epAwarded} EP');
          }
        } catch (epError) {
          debugPrint('Lỗi ghi nhận EP cho Writing submission: $epError');
        }
      }

      return id;
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        _errorMessage =
            'Không lưu được bài Writing.'
            '${statusCode != null ? ' ($statusCode)' : ''}';
      } else {
        _errorMessage = 'Không lưu được bài Writing. Vui lòng thử lại.';
      }
      debugPrint('Error saving writing submission: $e');
      notifyListeners();
      return null;
    }
  }

  /// Save a complete writing session with multiple answers (only save once when session is completed)
  Future<String?> saveSession({
    String? historyId,
    required List<String> questionIds,
    required Map<String, String> answers,
    required String sessionType,
    int? taskNumber,
    String? taskType,
    int? questionCount,
    int? correctCount,
    int? timeSpent,
    List<String>? incorrectIds,
    int? aiScore,
    WritingAiFeedback? aiFeedback,
  }) async {
    _errorMessage = null;
    try {
      final id = await _repository.saveSession(
        historyId: historyId,
        questionIds: questionIds,
        answers: answers,
        sessionType: sessionType,
        taskNumber: taskNumber,
        taskType: taskType,
        questionCount: questionCount,
        correctCount: correctCount,
        timeSpent: timeSpent,
        incorrectIds: incorrectIds,
        aiScore: aiScore,
        aiFeedback: aiFeedback,
      );
      await fetchHistory(forceRefresh: true);

      // Ghi nhận EP cho Writing session và cập nhật UI ngay lập tức
      if (id != null && sessionType == 'practice' && aiScore != null && aiScore > 0) {
        try {
          final userRepository = UserRepository();
          final epResult = await userRepository.recordActivity(
            activityType: 'WritingComplete',
            referenceId: id,
            correctAnswers: aiScore,
            totalAnswers: 10,
          );
          if (epResult != null) {
            _userProvider?.updateLocalEpAndStreak(epResult);
            debugPrint('✅ Writing Session EP: +${epResult.epAwarded} EP');
          }
        } catch (epError) {
          debugPrint('Lỗi ghi nhận EP cho Writing session: $epError');
        }
      }

      return id;
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        _errorMessage =
            'Không lưu được phiên Writing.'
            '${statusCode != null ? ' ($statusCode)' : ''}';
      } else {
        _errorMessage = 'Không lưu được phiên Writing. Vui lòng thử lại.';
      }
      debugPrint('Error saving writing session: $e');
      notifyListeners();
      return null;
    }
  }

  Future<WritingEvaluation?> evaluateAnswer(
    String questionId,
    String userAnswer,
  ) async {
    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastEvaluation = await _repository.evaluateWriting(
        questionId: questionId,
        userAnswer: userAnswer,
      );
      return _lastEvaluation;
    } catch (e) {
      _errorMessage = 'Lỗi chấm điểm AI: $e';
      return null;
    } finally {
      _isEvaluating = false;
      notifyListeners();
    }
  }

  void clearEvaluation() {
    _lastEvaluation = null;
    notifyListeners();
  }
}
