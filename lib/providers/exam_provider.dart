import 'package:flutter/foundation.dart';
import '../data/models/full_test_history_model.dart';
import '../data/models/listening_question.dart';
import '../data/models/speaking_exam_history_model.dart';
import '../data/models/writing_exam_history_model.dart';
import '../data/models/test_info.dart';
import '../data/repositories/exam_repository.dart';

class ExamProvider with ChangeNotifier {
  final ExamRepository _repository = ExamRepository();

  List<ListeningQuestion> _part12Questions = [];
  List<ListeningGroup> _part34Groups = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<dynamic> _examItems = []; // Contains ListeningQuestion (Part 1, 2, 5) and ListeningGroup (Part 3, 4, 6, 7)
  List<dynamic> get examItems => _examItems;

  List<int> _questionNumbers = [];
  List<int> get questionNumbers => _questionNumbers;

  int _totalQuestions = 0;
  int get totalQuestions => _totalQuestions;

  // --- Speaking, Writing, & Full Test Exam Histories ---
  List<SpeakingExamHistoryModel> _speakingExamHistories = [];
  List<SpeakingExamHistoryModel> get speakingExamHistories => _speakingExamHistories;

  List<WritingExamHistoryModel> _writingExamHistories = [];
  List<WritingExamHistoryModel> get writingExamHistories => _writingExamHistories;

  List<TestInfo> _exams = [];
  List<TestInfo> get exams => _exams;

  Future<void> fetchExams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _exams = await _repository.getExams();
      debugPrint('✅ [ExamProvider] Exams fetched: ${_exams.length}');
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách bài thi: $e';
      debugPrint('❌ [ExamProvider] Error fetching exams: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<FullTestHistoryModel> _fullTestHistories = [];
  List<FullTestHistoryModel> get fullTestHistories => _fullTestHistories;

  Future<void> fetchExamQuestions(String examId) async {
    _isLoading = true;
    _errorMessage = null;
    _examItems = [];
    _questionNumbers = [];
    _totalQuestions = 0;
    notifyListeners();

    try {
      final questions = await _repository.getQuestionsByExamId(examId);
      final groups = await _repository.getGroupsByExamId(examId);

      _part12Questions = questions.where((q) => q.part == 1 || q.part == 2 || q.part == 5).toList();
      _part34Groups = groups;

      // Sắp xếp các câu hỏi theo Part để gom thành 1 đề thi hoàn chỉnh
      // Part 1: Câu 1-6
      // Part 2: Câu 7-31
      // Part 3: Nhóm câu 32-70
      // Part 4: Nhóm câu 71-100
      // Part 5: Câu 101-130
      // Part 6: Nhóm câu 131-146
      // Part 7: Nhóm câu 147-200

      _part12Questions.sort((a, b) => a.id.compareTo(b.id));
      _part34Groups.sort((a, b) => a.id.compareTo(b.id));

      _examItems.addAll(_part12Questions.where((q) => q.part == 1));
      _examItems.addAll(_part12Questions.where((q) => q.part == 2));
      _examItems.addAll(_part34Groups.where((g) => g.part == 3));
      _examItems.addAll(_part34Groups.where((g) => g.part == 4));
      _examItems.addAll(_part12Questions.where((q) => q.part == 5));
      _examItems.addAll(_part34Groups.where((g) => g.part == 6));
      _examItems.addAll(_part34Groups.where((g) => g.part == 7));

      int currentNum = 1;
      for (var item in _examItems) {
        _questionNumbers.add(currentNum);
        if (item is ListeningQuestion) {
          currentNum += 1;
        } else if (item is ListeningGroup) {
          currentNum += item.questions.length;
        }
      }
      _totalQuestions = currentNum - 1;

    } catch (e) {
      _errorMessage = 'Lỗi kết nối API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FULL TEST EXAM ACTIONS ---

  Future<FullTestHistoryModel> submitFullTest({
    required String examId,
    required String examTitle,
    required int scoreListening,
    required int scoreReading,
    required int totalScore,
    required int correctCount,
    required int totalCount,
    required int timeSpent,
    required Map<String, String> answers,
    required Map<String, int> partScores,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.submitFullTest(
        examId: examId,
        examTitle: examTitle,
        scoreListening: scoreListening,
        scoreReading: scoreReading,
        totalScore: totalScore,
        correctCount: correctCount,
        totalCount: totalCount,
        timeSpent: timeSpent,
        answers: answers,
        partScores: partScores,
      );
      await fetchFullTestHistory();
      return result;
    } catch (e) {
      _errorMessage = 'Lỗi nộp bài thi Full Test: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFullTestHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fullTestHistories = await _repository.getFullTestHistory();
      debugPrint('✅ [ExamProvider] Full test histories fetched: ${_fullTestHistories.length}');
    } catch (e) {
      _errorMessage = 'Lỗi tải lịch sử thi Full Test: $e';
      debugPrint('❌ [ExamProvider] Error fetching Full Test history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- SPEAKING EXAM ACTIONS ---

  Future<SpeakingExamHistoryModel> submitSpeakingExam({
    required String examSetId,
    required String examTitle,
    required List<Map<String, dynamic>> tasks,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.submitSpeakingExam(
        examSetId: examSetId,
        examTitle: examTitle,
        tasks: tasks,
      );
      // Cập nhật lại list lịch sử tại local sau khi nộp
      await fetchSpeakingExamHistory();
      return result;
    } catch (e) {
      _errorMessage = 'Lỗi nộp bài thi Speaking: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSpeakingExamHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _speakingExamHistories = await _repository.getSpeakingExamHistory();
      debugPrint('✅ [ExamProvider] Speaking exam histories fetched: ${_speakingExamHistories.length}');
    } catch (e) {
      _errorMessage = 'Lỗi tải lịch sử thi Speaking: $e';
      debugPrint('❌ [ExamProvider] Error fetching Speaking exam history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- WRITING EXAM ACTIONS ---

  Future<WritingExamHistoryModel> submitWritingExam({
    required String examSetId,
    required String examTitle,
    required int timeSpent,
    required List<Map<String, dynamic>> tasks,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.submitWritingExam(
        examSetId: examSetId,
        examTitle: examTitle,
        timeSpent: timeSpent,
        tasks: tasks,
      );
      // Cập nhật lại list lịch sử tại local sau khi nộp
      await fetchWritingExamHistory();
      return result;
    } catch (e) {
      _errorMessage = 'Lỗi nộp bài thi Writing: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWritingExamHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _writingExamHistories = await _repository.getWritingExamHistory();
      debugPrint('✅ [ExamProvider] Writing exam histories fetched: ${_writingExamHistories.length}');
    } catch (e) {
      _errorMessage = 'Lỗi tải lịch sử thi Writing: $e';
      debugPrint('❌ [ExamProvider] Error fetching Writing exam history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
