import 'package:flutter/foundation.dart';
import '../data/models/listening_question.dart';
import '../data/repositories/listening_repository.dart';

class ListeningProvider with ChangeNotifier {
  final ListeningRepository _repository = ListeningRepository();

  List<ListeningQuestion> _questions = [];
  List<ListeningQuestion> get questions => _questions;

  List<ListeningGroup> _groups = [];
  List<ListeningGroup> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchQuestionsByPart(int partNumber, int requestedCount) async {
    _isLoading = true;
    _errorMessage = null;
    _questions = [];
    _groups = [];
    notifyListeners();

    try {
      if (partNumber == 1 || partNumber == 2) {
        final results = await _repository.getQuestionsByPart(partNumber);
        results.shuffle();
        _questions = results.take(requestedCount).toList();
      } else if (partNumber == 3 || partNumber == 4) {
        final results = await _repository.getGroupsByPart(partNumber);
        results.shuffle();
        _groups = results.take(requestedCount).toList();
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
