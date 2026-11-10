import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/user_profile_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/engagement_result_model.dart';

class UserRepository {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<Options> _getAuthOptions() async {
    final token = await _authService.getIdToken();
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<UserProfileModel> getProfile() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/users/me',
        options: options,
      );
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể lấy thông tin hồ sơ: ${_messageFromError(e)}');
    }
  }

  Future<UserProfileModel> updateProfile({
    int? targetScore,
    String? currentLevel,
    List<String>? preferredSkills,
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    String? gender,
    String? birthDate,
  }) async {
    try {
      final options = await _getAuthOptions();
      final data = <String, dynamic>{
        if (targetScore != null) 'targetScore': targetScore,
        if (currentLevel != null) 'currentLevel': currentLevel,
        if (preferredSkills != null) 'preferredSkills': preferredSkills,
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birthDate': birthDate,
      };

      final response = await _dio.patch(
        '${AppConstants.baseUrl}/users/me',
        data: data,
        options: options,
      );
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể cập nhật hồ sơ: ${_messageFromError(e)}');
    }
  }

  Future<List<LeaderboardEntryModel>> getWeeklyLeaderboard() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/leaderboard/weekly',
        queryParameters: {'limit': 50},
      );

      final List<dynamic> entriesJson = response.data['entries'] ?? [];
      return entriesJson
          .map((json) => LeaderboardEntryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy bảng xếp hạng tuần: $e');
    }
  }

  String _messageFromError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['detail'] ?? data['message'];
        if (message is String && message.isNotEmpty) return message;
      }
      if (data is String && data.isNotEmpty) return data;
      return error.message ?? 'Máy chủ đang gặp lỗi.';
    }
    return error.toString();
  }

  /// Ghi nhận hoạt động học và cộng EP
  /// [activityType]: 'VocabTyping' | 'VocabMatching' | 'VocabSentence' | 'VocabFlashcardReview'
  Future<EngagementResultModel?> recordActivity({
    required String activityType,
    String? referenceId,
    int correctAnswers = 0,
    int totalAnswers = 0,
    bool newlyMastered = false,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/engagement/activity',
        data: {
          'activityType': activityType,
          'referenceId': referenceId,
          'correctAnswers': correctAnswers,
          'totalAnswers': totalAnswers,
          'newlyMastered': newlyMastered,
        },
        options: options,
      );
      return EngagementResultModel.fromJson(response.data);
    } catch (e) {
      // Không throw — EP lỗi không ảnh hưởng truyền thông
      return null;
    }
  }
}
