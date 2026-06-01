import 'package:flutter/foundation.dart';
import '../data/models/reading_part5_model.dart';
import '../data/repositories/reading_part5_repository.dart';

class ReadingPart5Provider with ChangeNotifier {
  final ReadingPart5Repository _repo = ReadingPart5Repository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ReadingPart5Question> _questions = [];
  List<ReadingPart5Question> get questions => _questions;

  ReadingPart5SubmitResult? _lastSubmitResult;
  ReadingPart5SubmitResult? get lastSubmitResult => _lastSubmitResult;

  Future<void> fetchQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _questions = await _repo.getQuestions();
      // debug
      // ignore: avoid_print
      print('ReadingPart5Provider.fetchQuestions: loaded ${_questions.length} questions');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReadingPart5SubmitResult> submitAnswers(Map<String, int?> answers) async {
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
}
