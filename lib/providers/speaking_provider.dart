import 'package:flutter/foundation.dart';
import '../data/models/speaking_question.dart';
import '../data/models/speaking_evaluation_model.dart';
import '../data/repositories/speaking_repository.dart';

class SpeakingProvider with ChangeNotifier {
  final SpeakingRepository _repository = SpeakingRepository();

  List<SpeakingQuestion> _questions = [];
  List<SpeakingQuestion> get questions => _questions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEvaluating = false;
  bool get isEvaluating => _isEvaluating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SpeakingEvaluation? _lastEvaluation;
  SpeakingEvaluation? get lastEvaluation => _lastEvaluation;

  /// Tải câu hỏi dựa trên Part (Index) khớp trực tiếp với Task Number của Backend:
  /// Part 1 -> Task 1, Part 2 -> Task 2, Part 3 -> Task 3 (3 câu con), Part 5 -> Task 5
  Future<void> fetchQuestionsByPart(int partIndex) async {
    _isLoading = true;
    _errorMessage = null;
    _questions = [];
    notifyListeners();

    try {
      List<int> taskNumbers = [partIndex];

      List<SpeakingQuestion> allFetched = [];
      for (var taskNum in taskNumbers) {
        try {
          final results = await _repository.getQuestionsByTaskNumber(taskNum);
          allFetched.addAll(results);
        } catch (e) {
          debugPrint('Error fetching task $taskNum: $e');
        }
      }

      if (allFetched.isEmpty) {
        _questions = SpeakingQuestionData.byPart[partIndex] ?? [];
      } else {
        _questions = allFetched;
      }
      
    } catch (e) {
      _errorMessage = 'Lỗi kết nối API. Đang dùng dữ liệu mẫu.';
      _questions = SpeakingQuestionData.byPart[partIndex] ?? [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gửi bài nói lên AI để chấm điểm.
  /// Đối với Task 3 & 4, truyền subQuestionIndex (0, 1, 2) để Backend chấm đúng câu hỏi.
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
