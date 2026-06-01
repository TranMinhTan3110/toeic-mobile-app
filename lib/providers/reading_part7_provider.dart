import 'package:flutter/foundation.dart';
import '../data/models/reading_part7_model.dart';
import '../data/repositories/reading_part7_repository.dart';

class ReadingPart7Provider with ChangeNotifier {
  final ReadingPart7Repository _repo = ReadingPart7Repository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ReadingPart7Passage> _passages = [];
  List<ReadingPart7Passage> get passages => _passages;

  ReadingPart7SubmitResult? _lastSubmitResult;
  ReadingPart7SubmitResult? get lastSubmitResult => _lastSubmitResult;

  Future<void> fetchPassages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _passages = await _repo.getPassages();
      // ignore: avoid_print
      print('ReadingPart7Provider.fetchPassages: loaded ${_passages.length} passages');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReadingPart7SubmitResult> submitAnswers(Map<String, int?> answers) async {
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
