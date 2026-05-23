import 'package:flutter/foundation.dart';
import '../data/models/speaking_question.dart';
import '../data/models/speaking_evaluation_model.dart';
import '../data/repositories/speaking_repository.dart';

class SpeakingProvider with ChangeNotifier {
  final SpeakingRepository _repository = SpeakingRepository();

  // Lưu trữ câu hỏi theo từng part để tránh bị ghi đè khi tải nhiều part
  final Map<int, List<SpeakingQuestion>> _questionsByPart = {};
  
  /// Trả về tất cả câu hỏi đã tải
  List<SpeakingQuestion> get questions => _questionsByPart.values.expand((e) => e).toList();

  /// Lấy danh sách câu hỏi của một Part cụ thể
  List<SpeakingQuestion> getQuestionsForPart(int partNumber) => 
      _questionsByPart[partNumber] ?? [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEvaluating = false;
  bool get isEvaluating => _isEvaluating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SpeakingEvaluation? _lastEvaluation;
  SpeakingEvaluation? get lastEvaluation => _lastEvaluation;

  /// Tải câu hỏi dựa trên Part (Task Number)
  Future<void> fetchQuestionsByPart(int partNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getQuestionsByTaskNumber(partNumber);
      
      if (results.isEmpty) {
        _questionsByPart[partNumber] = SpeakingQuestionData.byPart[partNumber] ?? [];
      } else {
        _questionsByPart[partNumber] = results;
      }
      
    } catch (e) {
      debugPrint('Error fetching part $partNumber: $e');
      _errorMessage = 'Lỗi kết nối API. Đang dùng dữ liệu mẫu.';
      _questionsByPart[partNumber] = SpeakingQuestionData.byPart[partNumber] ?? [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gửi bài nói lên AI để chấm điểm
  Future<SpeakingEvaluation?> evaluateAnswer(
    String questionId, 
    String audioPath, {
    int? subQuestionIndex,
  }) async {
    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastEvaluation = await _repository.evaluateSpeaking(
        questionId: questionId,
        audioPath: audioPath,
        subQuestionIndex: subQuestionIndex,
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
