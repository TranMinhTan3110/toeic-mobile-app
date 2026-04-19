import 'package:flutter/material.dart';
import '../data/models/vocabulary_model.dart';
import '../data/repositories/vocabulary_repository.dart';

class VocabularyProvider with ChangeNotifier {
  final VocabularyRepository _repository = VocabularyRepository();
  
  List<VocabularyModel> _words = [];
  List<VocabularyModel> get words => _words;

  List<String> _topics = [];
  List<String> get topics => _topics;

  List<String> _levels = [];
  List<String> get levels => _levels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Tải danh sách chủ đề và cấp độ từ API
  Future<void> fetchMetadata() async {
    try {
      _topics = await _repository.getTopics();
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching metadata: $e');
    }
  }

  // Gọi hàm này để fetch data dựa trên topic và level
  Future<void> fetchVocabularies(String topic, String level) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _words = await _repository.getVocabularies(topic, level);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleStar(String id) {
    final index = _words.indexWhere((w) => w.id == id);
    if (index != -1) {
      _words[index] = _words[index].copyWith(isStarred: !_words[index].isStarred);
      notifyListeners();
    }
  }
}
