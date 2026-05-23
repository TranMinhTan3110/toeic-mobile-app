import 'package:flutter/foundation.dart';
import '../data/models/speaking_question.dart';
import '../data/models/speaking_evaluation_model.dart';
import '../data/repositories/speaking_repository.dart';

class SpeakingProvider with ChangeNotifier {
  final SpeakingRepository _repository = SpeakingRepository();

  // part + practice|exam → danh sách câu hỏi
  final Map<String, List<SpeakingQuestion>> _questionsByPart = {};

  static String _cacheKey(int partNumber, bool practiceMode) =>
      '$partNumber-${practiceMode ? 'practice' : 'exam'}';

  /// Trả về tất cả câu hỏi đã tải
  List<SpeakingQuestion> get questions =>
      _questionsByPart.values.expand((e) => e).toList();

  /// Lấy danh sách câu hỏi của một Part (mặc định: luyện tập)
  List<SpeakingQuestion> getQuestionsForPart(
    int partNumber, {
    bool practiceMode = true,
  }) =>
      _questionsByPart[_cacheKey(partNumber, practiceMode)] ?? [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEvaluating = false;
  bool get isEvaluating => _isEvaluating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SpeakingEvaluation? _lastEvaluation;
  SpeakingEvaluation? get lastEvaluation => _lastEvaluation;

  /// Tải câu hỏi theo Part. [practiceMode] true → chỉ lấy is_practice trên Firestore.
  Future<void> fetchQuestionsByPart(
    int partNumber, {
    bool practiceMode = true,
  }) async {
    final cacheKey = _cacheKey(partNumber, practiceMode);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getQuestionsByTaskNumber(
        partNumber,
        isPractice: practiceMode ? true : null,
        isExam: practiceMode ? null : true,
      );

      if (results.isEmpty) {
        debugPrint(
          'API returned empty for part $partNumber (practice=$practiceMode), using mock.',
        );
        _questionsByPart[cacheKey] = SpeakingQuestionData.byPart[partNumber] ?? [];
      } else {
        _questionsByPart[cacheKey] =
            _enrichWithMockExplanations(results, partNumber);
      }
    } catch (e) {
      debugPrint('Error fetching part $partNumber: $e');
      _errorMessage = 'Lỗi kết nối API. Đang dùng dữ liệu mẫu.';
      _questionsByPart[cacheKey] = SpeakingQuestionData.byPart[partNumber] ?? [];
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

  /// Bổ sung explanation từ mock khi API có câu hỏi nhưng thiếu bài mẫu / dịch.
  List<SpeakingQuestion> _enrichWithMockExplanations(
    List<SpeakingQuestion> fromApi,
    int partNumber,
  ) {
    final mocks = SpeakingQuestionData.byPart[partNumber] ?? [];
    return fromApi.map((q) {
      var enriched = q.withNormalizedExplanation();
      if (enriched.hasExplanationContent || mocks.isEmpty) return enriched;

      for (final mock in mocks) {
        if (SpeakingQuestion.matchesMock(enriched, mock)) {
          return enriched.mergeExplanationFrom(mock);
        }
      }
      return enriched;
    }).toList();
  }
}
