import 'package:flutter/foundation.dart';
import '../data/models/speaking_question.dart';
import '../data/models/speaking_evaluation_model.dart';
import '../data/models/speaking_history_model.dart';
import '../data/models/speaking_part_info.dart';
import '../data/models/speaking_history_item.dart';
import '../data/repositories/speaking_repository.dart';

class SpeakingProvider with ChangeNotifier {
  final SpeakingRepository _repository = SpeakingRepository();

  final Map<String, List<SpeakingQuestion>> _questionsByPart = {};

  static String _cacheKey(int partNumber, bool practiceMode) =>
      '$partNumber-${practiceMode ? 'practice' : 'exam'}';

  List<SpeakingQuestion> get questions =>
      _questionsByPart.values.expand((e) => e).toList();

  List<SpeakingQuestion> getQuestionsForPart(
    int partNumber, {
    bool practiceMode = true,
  }) =>
      _questionsByPart[_cacheKey(partNumber, practiceMode)] ?? [];

  SpeakingQuestion? getQuestionById(String questionId) {
    for (var questions in _questionsByPart.values) {
      final question = questions.firstWhere(
        (q) => q.id == questionId,
        orElse: () => SpeakingQuestion(
          id: '',
          taskNumber: 0,
          prepSeconds: 0,
          recordSeconds: 0,
          text: '',
        ),
      );
      if (question.id.isNotEmpty) return question;
    }
    return null;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  bool _isEvaluating = false;
  bool get isEvaluating => _isEvaluating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SpeakingEvaluation? _lastEvaluation;
  SpeakingEvaluation? get lastEvaluation => _lastEvaluation;

  List<SpeakingHistoryItem> _historyItems = [];
  List<SpeakingHistoryItem> get historyItems => _historyItems;

  SpeakingHistoryModel? _selectedHistory;
  SpeakingHistoryModel? get selectedHistory => _selectedHistory;

  final List<SpeakingHistoryAnswerModel> _currentSessionAnswers = [];
  List<SpeakingHistoryAnswerModel> get currentSessionAnswers =>
      List.unmodifiable(_currentSessionAnswers);

  void clearSessionAnswers() {
    _currentSessionAnswers.clear();
    notifyListeners();
  }

  void addSessionAnswer(SpeakingHistoryAnswerModel answer) {
    _currentSessionAnswers.add(answer);
    notifyListeners();
  }

  Future<void> fetchHistory({String? sessionType, bool forceRefresh = false}) async {
    if (!forceRefresh && _historyItems.isNotEmpty) return;

    _isHistoryLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lấy tất cả lịch sử (practice & exam)
      final models = await _repository.getHistory(sessionType: sessionType);
      _historyItems = models
          .map((m) => _mapToHistoryItem(m))
          .toList();
    } catch (e) {
      debugPrint('Error fetching speaking history: $e');
      _errorMessage = 'Không tải được lịch sử luyện nói.';
      _historyItems = [];
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<SpeakingHistoryModel?> fetchHistoryDetail(String id) async {
    try {
      _selectedHistory = await _repository.getHistoryById(id);
      notifyListeners();
      return _selectedHistory;
    } catch (e) {
      debugPrint('Error fetching history detail: $e');
      return null;
    }
  }

  Future<String?> saveSessionHistory({
    required int part,
    required bool examMode,
    List<SpeakingQuestion>? allTasks,
  }) async {
    // Lưu lịch sử với tất cả các câu (những câu không làm sẽ có transcript trống)
    final answersToSave = <SpeakingHistoryAnswerModel>[];
    
    if (allTasks != null && allTasks.isNotEmpty) {
      // Lặp qua tất cả các task
      for (final task in allTasks) {
        // Tìm answer cho task này
        final existingAnswer = _currentSessionAnswers.firstWhere(
          (a) => a.questionId == task.id,
          orElse: () => SpeakingHistoryAnswerModel(
            questionId: task.id,
            transcript: '',
            audioUrl: '',
            overallScore: 0.0,
            passed: false,
            feedback: '',
            criteriaScores: {},
          ),
        );
        answersToSave.add(existingAnswer);
      }
    } else {
      // Nếu không truyền allTasks, chỉ lưu những câu đã làm
      answersToSave.addAll(_currentSessionAnswers);
    }

    final total = answersToSave.length;
    final correct = answersToSave.where((a) => a.passed).length;
    final percent = total > 0 ? (correct / total) * 100 : 0.0;
    final avgScore = answersToSave.isNotEmpty
        ? answersToSave.map((a) => a.overallScore).reduce((a, b) => a + b) /
            answersToSave.length
        : 0.0;

    final criteria = <String, double>{};
    for (final answer in answersToSave) {
      answer.criteriaScores.forEach((key, value) {
        criteria[key] = criteria.containsKey(key)
            ? (criteria[key]! + value) / 2
            : value;
      });
    }

    final feedbackSummary = answersToSave
        .map((a) => a.feedback)
        .where((f) => f.isNotEmpty)
        .take(2)
        .join(' ');

    try {
      final id = await _repository.saveHistory(
        part: part,
        correctCount: correct,
        totalCount: total,
        percent: percent,
        score: avgScore,
        feedbackSummary: feedbackSummary.isNotEmpty
            ? feedbackSummary
            : 'Hoàn thành phiên luyện tập Part $part.',
        criteria: criteria,
        answers: answersToSave,
        sessionType: examMode ? 'exam' : 'practice',
      );
      _currentSessionAnswers.clear();
      await fetchHistory(forceRefresh: true);
      return id;
    } catch (e) {
      debugPrint('Error saving speaking history: $e');
      _errorMessage = 'Không lưu được lịch sử luyện tập: $e';
      notifyListeners();
      return null;
    }
  }

  SpeakingHistoryItem _mapToHistoryItem(SpeakingHistoryModel model) {
    SpeakingPartInfo partInfo;
    try {
      partInfo = SpeakingPartInfo.parts
          .firstWhere((p) => p.partNumber == model.part);
    } catch (_) {
      partInfo = SpeakingPartInfo.parts.first;
    }

    final dateStr =
        '${model.date.day.toString().padLeft(2, '0')}/${model.date.month.toString().padLeft(2, '0')}/${model.date.year}';

    return SpeakingHistoryItem(
      historyId: model.id,
      attemptNumber: 0,
      partNumber: model.part,
      partTitle: 'Phần ${model.part} – ${partInfo.titleVi}',
      correctCount: model.correctCount,
      totalQuestions: model.totalCount,
      date: dateStr,
      score: model.score,
      feedbackSummary: model.feedbackSummary,
      criteria: model.criteria.isNotEmpty
          ? model.criteria
          : {'Tổng điểm': model.score},
    );
  }

  Future<void> fetchQuestionsByPart(
    int partNumber, {
    bool practiceMode = true,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKey(partNumber, practiceMode);
    if (!forceRefresh &&
        _questionsByPart.containsKey(cacheKey) &&
        _questionsByPart[cacheKey]!.isNotEmpty) {
      return;
    }
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

  Future<SpeakingEvaluation?> evaluateAnswer(
    String questionId,
    String audioPath, {
    int? subQuestionIndex,
    String transcript = '',
  }) async {
    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastEvaluation = await _repository.evaluateSpeaking(
        questionId: questionId,
        audioPath: audioPath,
        transcript: transcript,
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
