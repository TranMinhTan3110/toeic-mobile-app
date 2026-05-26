import 'package:flutter/foundation.dart';
import '../data/models/user_profile_model.dart';
import '../data/models/leaderboard_entry_model.dart';
import '../data/models/engagement_result_model.dart';
import '../data/repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserProfileModel? _profile;
  UserProfileModel? get profile => _profile;

  List<LeaderboardEntryModel> _leaderboard = [];
  List<LeaderboardEntryModel> get leaderboard => _leaderboard;

  bool _isLoadingProfile = false;
  bool get isLoadingProfile => _isLoadingProfile;

  bool _isLoadingLeaderboard = false;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;

  String? _profileError;
  String? get profileError => _profileError;

  String? _leaderboardError;
  String? get leaderboardError => _leaderboardError;

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (_profile != null && !forceRefresh) {
      debugPrint('ℹ️ [UserProvider] Profile already loaded. Using cached profile.');
      return;
    }

    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      debugPrint('🔄 [UserProvider] Fetching profile from API...');
      _profile = await _userRepository.getProfile();
      debugPrint('✅ [UserProvider] Profile loaded: ${_profile?.displayName} | EP: ${_profile?.experiencePoints}');
    } catch (e) {
      _profileError = e.toString();
      debugPrint('❌ [UserProvider] Error fetching user profile: $e');
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required int targetScore,
    required String currentLevel,
    required List<String> preferredSkills,
  }) async {
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      _profile = await _userRepository.updateProfile(
        targetScore: targetScore,
        currentLevel: currentLevel,
        preferredSkills: preferredSkills,
      );
    } catch (e) {
      _profileError = e.toString();
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaderboard({bool forceRefresh = false}) async {
    if (_leaderboard.isNotEmpty && !forceRefresh) {
      debugPrint('ℹ️ [UserProvider] Leaderboard already loaded. Using cached leaderboard.');
      return;
    }

    _isLoadingLeaderboard = true;
    _leaderboardError = null;
    notifyListeners();

    try {
      debugPrint('🔄 [UserProvider] Fetching leaderboard from API...');
      _leaderboard = await _userRepository.getWeeklyLeaderboard();
      debugPrint('✅ [UserProvider] Leaderboard loaded: ${_leaderboard.length} entries.');
    } catch (e) {
      _leaderboardError = e.toString();
      debugPrint('Error fetching leaderboard: $e');
    } finally {
      _isLoadingLeaderboard = false;
      notifyListeners();
    }
  }

  void updateLocalEpAndStreak(EngagementResultModel engagement) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      experiencePoints: engagement.totalExperiencePoints,
      weeklyEp: engagement.weeklyEp,
      streakDays: engagement.streakDays,
      bestStreakDays: engagement.bestStreakDays,
    );

    // Cập nhật điểm của mình trên Bảng xếp hạng nếu có mặt
    final index = _leaderboard.indexWhere((entry) => entry.uid == _profile!.uid);
    if (index != -1) {
      final oldEntry = _leaderboard[index];
      _leaderboard[index] = LeaderboardEntryModel(
        rank: oldEntry.rank,
        uid: oldEntry.uid,
        displayName: oldEntry.displayName,
        avatarUrl: oldEntry.avatarUrl,
        weeklyEp: engagement.weeklyEp,
        streakDays: engagement.streakDays,
      );
      // Sắp xếp lại bảng xếp hạng dựa trên weeklyEp giảm dần
      _leaderboard.sort((a, b) => b.weeklyEp.compareTo(a.weeklyEp));
      // Gán lại rank sau khi sort
      for (int i = 0; i < _leaderboard.length; i++) {
        final e = _leaderboard[i];
        _leaderboard[i] = LeaderboardEntryModel(
          rank: i + 1,
          uid: e.uid,
          displayName: e.displayName,
          avatarUrl: e.avatarUrl,
          weeklyEp: e.weeklyEp,
          streakDays: e.streakDays,
        );
      }
    }

    notifyListeners();
  }

  void clear() {
    _profile = null;
    _leaderboard = [];
    _profileError = null;
    _leaderboardError = null;
    notifyListeners();
  }

  /// Ghi nhận hoạt động học và cộng EP — gọi sau khi hoàn thành Quiz/Matching/AI Writing
  Future<EngagementResultModel?> recordActivity({
    required String activityType,
    String? referenceId,
    int correctAnswers = 0,
    int totalAnswers = 0,
    bool newlyMastered = false,
  }) async {
    try {
      final result = await _userRepository.recordActivity(
        activityType   : activityType,
        referenceId    : referenceId,
        correctAnswers : correctAnswers,
        totalAnswers   : totalAnswers,
        newlyMastered  : newlyMastered,
      );
      if (result != null) {
        updateLocalEpAndStreak(result);
      }
      return result;
    } catch (_) {
      return null;
    }
  }
}
