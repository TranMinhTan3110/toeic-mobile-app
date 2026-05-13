import 'package:flutter/foundation.dart';
import '../data/models/reading_part6_model.dart';
import '../data/repositories/reading_part6_repository.dart';

class ReadingPart6Provider with ChangeNotifier {
  final ReadingPart6Repository _repo = ReadingPart6Repository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ReadingPart6Passage> _passages = [];
  List<ReadingPart6Passage> get passages => _passages;

  ReadingPart6SubmitResult? _lastSubmitResult;
  ReadingPart6SubmitResult? get lastSubmitResult => _lastSubmitResult;

  Future<void> fetchPassages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _passages = await _repo.getPassages();
      // ignore: avoid_print
      print('ReadingPart6Provider.fetchPassages: loaded ${_passages.length} passages');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReadingPart6SubmitResult> submitAnswers(Map<String, int?> answers) async {
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
