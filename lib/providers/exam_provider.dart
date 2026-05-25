import 'package:flutter/foundation.dart';
import '../data/models/listening_question.dart';
import '../data/repositories/exam_repository.dart';

class ExamProvider with ChangeNotifier {
  final ExamRepository _repository = ExamRepository();

  List<ListeningQuestion> _part12Questions = [];
  List<ListeningGroup> _part34Groups = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<dynamic> _examItems = []; // Contains ListeningQuestion (Part 1, 2) and ListeningGroup (Part 3, 4)
  List<dynamic> get examItems => _examItems;

  List<int> _questionNumbers = [];
  List<int> get questionNumbers => _questionNumbers;

  int _totalQuestions = 0;
  int get totalQuestions => _totalQuestions;

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

      _part12Questions = questions.where((q) => q.part == 1 || q.part == 2).toList();
      _part34Groups = groups;

      // Sắp xếp các câu hỏi theo Part để gom thành 1 đề thi hoàn chỉnh
      // Part 1: Câu 1-6
      // Part 2: Câu 7-31
      // Part 3: Nhóm câu 32-70
      // Part 4: Nhóm câu 71-100

      _part12Questions.sort((a, b) => a.id.compareTo(b.id)); // Tạm thời sort theo id hoặc có thể thêm order
      _part34Groups.sort((a, b) => a.id.compareTo(b.id));

      _examItems.addAll(_part12Questions.where((q) => q.part == 1));
      _examItems.addAll(_part12Questions.where((q) => q.part == 2));
      _examItems.addAll(_part34Groups.where((g) => g.part == 3));
      _examItems.addAll(_part34Groups.where((g) => g.part == 4));

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
}
