import 'package:flutter/foundation.dart';
import '../data/models/listening_question.dart';
import '../data/repositories/listening_repository.dart';

class ListeningProvider with ChangeNotifier {
  final ListeningRepository _repository = ListeningRepository();

  List<ListeningQuestion> _questions = [];
  List<ListeningQuestion> get questions => _questions;

  List<ListeningGroup> _groups = [];
  List<ListeningGroup> get groups => _groups;

  /// Cache count (nhẹ) — trả về ngay lập tức không cần gọi API lại.
  final Map<int, int> _countCache = {};

  /// Cache toàn bộ câu hỏi Part 1/2.
  final Map<int, List<ListeningQuestion>> _questionsCache = {};

  /// Cache toàn bộ nhóm Part 3/4.
  final Map<int, List<ListeningGroup>> _groupsCache = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Bước 1: Lấy số câu (siêu nhanh) ──────────────────────────────────────
  // Gọi từ DetailScreen để hiển thị số câu NGAY LẬP TỨC.
  // Chỉ gọi API count (1 Firestore read). Đồng thời kick off preload ở background.

  Future<int> getCountByPart(int partNumber) async {
    // Cache hit → trả về ngay, 0ms
    if (_countCache.containsKey(partNumber)) {
      return _countCache[partNumber]!;
    }
    // Cache miss → gọi API count (nhanh, chỉ 1 read)
    final count = await _repository.getCountByPart(partNumber);
    _countCache[partNumber] = count;
    return count;
  }

  // ── Bước 2: Preload data ở background ─────────────────────────────────────
  // Gọi ngay sau getCountByPart() mà KHÔNG await — chạy ngầm.
  // Khi user bấm "Bắt đầu", data đã sẵn trong cache.

  void preloadInBackground(int partNumber) {
    if (partNumber <= 2) {
      if (_questionsCache.containsKey(partNumber)) return; // Đã có rồi
      _repository.getQuestionsByPart(partNumber).then((list) {
        _questionsCache[partNumber] = list;
        // Cập nhật count cache từ data thật (chính xác hơn)
        _countCache[partNumber] = list.length;
      }).catchError((e) {
        debugPrint('[Preload P$partNumber] $e');
      });
    } else {
      if (_groupsCache.containsKey(partNumber)) return; // Đã có rồi
      _repository.getGroupsByPart(partNumber).then((list) {
        _groupsCache[partNumber] = list;
        _countCache[partNumber] = list.length;
      }).catchError((e) {
        debugPrint('[Preload P$partNumber] $e');
      });
    }
  }
  /// Preload toàn bộ 4 Part trong background khi user vừa mở app / vào menu Nghe.
  /// Giúp trải nghiệm cực kỳ mượt mà, khi click vào bất kỳ Part nào cũng là INSTANT.
  void preloadAllParts() {
    for (int part = 1; part <= 4; part++) {
      getCountByPart(part).then((_) {
        preloadInBackground(part);
      }).catchError((e) {
        debugPrint('[PreloadAll P$part] $e');
      });
    }
  }
  // ── Bước 3: Load vào PracticeScreen ───────────────────────────────────────
  // Nếu cache có sẵn (preload xong) → KHÔNG show loading spinner, instant.
  // Nếu chưa có → show spinner và fetch.

  Future<void> fetchQuestionsByPart(int partNumber, int requestedCount) async {
    final hasCachedData = partNumber <= 2
        ? _questionsCache.containsKey(partNumber)
        : _groupsCache.containsKey(partNumber);

    // Chỉ show loading nếu chưa có cache
    if (!hasCachedData) {
      _isLoading = true;
      _errorMessage = null;
      _questions = [];
      _groups = [];
      notifyListeners();
    }

    try {
      if (partNumber == 1 || partNumber == 2) {
        List<ListeningQuestion> pool;
        if (_questionsCache.containsKey(partNumber)) {
          pool = List<ListeningQuestion>.from(_questionsCache[partNumber]!);
        } else {
          pool = await _repository.getQuestionsByPart(partNumber);
          _questionsCache[partNumber] = pool;
          _countCache[partNumber] = pool.length;
        }
        pool.shuffle();
        _questions = pool.take(requestedCount).toList();
      } else if (partNumber == 3 || partNumber == 4) {
        List<ListeningGroup> pool;
        if (_groupsCache.containsKey(partNumber)) {
          pool = List<ListeningGroup>.from(_groupsCache[partNumber]!);
        } else {
          pool = await _repository.getGroupsByPart(partNumber);
          _groupsCache[partNumber] = pool;
          _countCache[partNumber] = pool.length;
        }
        pool.shuffle();
        _groups = pool.take(requestedCount).toList();
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xóa toàn bộ cache (ví dụ: pull-to-refresh).
  void clearCache() {
    _countCache.clear();
    _questionsCache.clear();
    _groupsCache.clear();
  }

  void clearGroupsCache() => _groupsCache.clear();
}
