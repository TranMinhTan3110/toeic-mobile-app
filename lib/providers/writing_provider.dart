import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/models/writing_history_item.dart';
import '../data/repositories/writing_repository.dart';

class WritingProvider with ChangeNotifier {
  final WritingRepository _repository = WritingRepository();

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<WritingHistoryItem> _historyItems = [];
  List<WritingHistoryItem> get historyItems => _historyItems;

  WritingHistoryItem? _selectedSubmission;
  WritingHistoryItem? get selectedSubmission => _selectedSubmission;

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
      if (e is DioError) {
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
    String? questionId,
    String sessionType = 'practice',
    String? userAnswer,
    List<String>? questionIds,
    Map<String, String>? answers,
    int? questionCount,
    int? taskNumber,
    String? taskType,
    int? wordCount,
    int? timeUsed,
  }) async {
    _errorMessage = null;
    try {
      final id = await _repository.saveSubmission(
        questionId: questionId,
        sessionType: sessionType,
        userAnswer: userAnswer,
        questionIds: questionIds,
        answers: answers,
        questionCount: questionCount,
        taskNumber: taskNumber,
        taskType: taskType,
        wordCount: wordCount,
        timeUsed: timeUsed,
      );
      await fetchHistory(forceRefresh: true);
      return id;
    } catch (e) {
      if (e is DioError) {
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
}
