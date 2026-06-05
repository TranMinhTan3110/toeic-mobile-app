import 'package:flutter/foundation.dart';
import '../data/models/vocabulary_display_mode.dart';
import '../data/models/vocabulary_model.dart';
import '../data/models/vocabulary_hub_stats.dart';
import '../data/repositories/vocabulary_repository.dart';

class VocabularyProvider with ChangeNotifier {
  final VocabularyRepository _repository = VocabularyRepository();

  // ── Display mode ────────────────────────────────────────────────────────────
  VocabularyDisplayMode _displayMode = VocabularyDisplayMode.all;
  VocabularyDisplayMode get displayMode => _displayMode;

  void setDisplayMode(VocabularyDisplayMode mode) {
    _displayMode = (_displayMode == mode) ? VocabularyDisplayMode.all : mode;
    notifyListeners();
  }

  // ── Vocabulary list ─────────────────────────────────────────────────────────
  List<VocabularyModel> _words = [];
  List<VocabularyModel> get words => _words;

  List<String> _topics = [];
  List<String> get topics => _topics;

  List<String> _levels = [];
  List<String> get levels => _levels;

  // ── Hub Stats ───────────────────────────────────────────────────────────────
  VocabularyHubStats? _hubStats;
  VocabularyHubStats? get hubStats => _hubStats;

  bool _isLoadingHub = false;
  bool get isLoadingHub => _isLoadingHub;

  String? _hubError;
  String? get hubError => _hubError;

  // ── Starred (Notebook) ──────────────────────────────────────────────────────
  List<VocabularyModel> _starredWords = [];
  List<VocabularyModel> get starredWords => _starredWords;

  bool _isLoadingStarred = false;
  bool get isLoadingStarred => _isLoadingStarred;

  String? _starredError;
  String? get starredError => _starredError;

  // ── Loading / Error (chung) ─────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Track last query & Cache ──────────────────────────────────────────────
  String? _lastTopic;
  String? _lastLevel;
  final Map<String, List<VocabularyModel>> _cacheWords = {};

  // ── Methods ─────────────────────────────────────────────────────────────────

  /// Tải metadata (topics + levels)
  Future<void> fetchMetadata({bool forceRefresh = false}) async {
    if (_topics.isNotEmpty && _levels.isNotEmpty && !forceRefresh) {
      debugPrint('ℹ[VocabularyProvider] Metadata already loaded. Using cache.');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _topics = await _repository.getTopics();
      _levels = await _repository.getLevels();
    } catch (e) {
      _errorMessage = 'Không thể kết nối đến máy chủ. Kiểm tra Wifi và IP: $e';
      debugPrint('Error fetching metadata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải danh sách từ theo topic + level
  Future<void> fetchVocabularies(String topic, String level, {bool forceRefresh = false}) async {
    final cacheKey = '$topic-$level';

    // Nếu không bắt buộc tải lại và đã có cache cho topic-level này thì dùng luôn
    if (!forceRefresh && _cacheWords.containsKey(cacheKey) && _cacheWords[cacheKey]!.isNotEmpty) {
      debugPrint('ℹ[VocabularyProvider] Words for topic "$topic", level "$level" loaded from cache.');
      _words = _cacheWords[cacheKey]!;
      _lastTopic = topic;
      _lastLevel = level;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _lastTopic = topic;
    _lastLevel = level;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedWords = await _repository.getVocabularies(topic, level);
      _words = fetchedWords;
      _cacheWords[cacheKey] = fetchedWords; // Lưu vào cache
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải thông số Hub (số từ đã lưu, cần ôn, đã học, thành thạo)
  Future<void> fetchHubStats({bool forceRefresh = false}) async {
    if (_hubStats != null && !forceRefresh) {
      debugPrint(' [VocabularyProvider] Hub stats already loaded. Using cache.');
      return;
    }

    _isLoadingHub = true;
    _hubError = null;
    notifyListeners();
    try {
      _hubStats = await _repository.getHubStats();
    } catch (e) {
      _hubError = e.toString();
      debugPrint('Error fetching hub stats: $e');
    } finally {
      _isLoadingHub = false;
      notifyListeners();
    }
  }

  /// Tải danh sách từ đã lưu vào sổ tay
  Future<void> fetchStarredVocabularies({bool forceRefresh = false}) async {
    if (_starredWords.isNotEmpty && !forceRefresh) {
      debugPrint(' [VocabularyProvider] Starred words already loaded. Using cache.');
      return;
    }

    _isLoadingStarred = true;
    _starredError = null;
    notifyListeners();
    try {
      _starredWords = await _repository.getStarredVocabularies();
    } catch (e) {
      _starredError = e.toString();
      debugPrint('Error fetching starred: $e');
    } finally {
      _isLoadingStarred = false;
      notifyListeners();
    }
  }

  /// Toggle star (optimistic update + sync API)
  void toggleStar(String id) {
    final index = _words.indexWhere((w) => w.id == id);
    if (index != -1) {
      _words[index] = _words[index].copyWith(isStarred: !_words[index].isStarred);
      notifyListeners();
      // Sync lên server
      _repository.toggleStar(id).catchError((e) {
        debugPrint('Toggle star sync error: $e');
        if (index < _words.length) {
          _words[index] = _words[index].copyWith(isStarred: !_words[index].isStarred);
          notifyListeners();
        }
      });
    }
  }

  /// Toggle star từ trong sổ tay (remove khỏi list starred)
  Future<void> toggleStarFromNotebook(String id) async {
    try {
      await _repository.toggleStar(id);
      _starredWords.removeWhere((w) => w.id == id);
      if (_hubStats != null) {
        _hubStats = _hubStats!.copyWith(
          starredCount: (_hubStats!.starredCount - 1).clamp(0, 9999),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Toggle star from notebook error: $e');
    }
  }

  void clearCache() {
    _words = [];
    _topics = [];
    _levels = [];
    _hubStats = null;
    _starredWords = [];
    _cacheWords.clear();
    _lastTopic = null;
    _lastLevel = null;
    notifyListeners();
  }
}
