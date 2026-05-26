import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/vocabulary_model.dart';
import '../models/vocabulary_hub_stats.dart';
import '../models/update_progress_result.dart';

class VocabularyRepository {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<Options> _getAuthOptions() async {
    final token = await _authService.getIdToken();
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<List<VocabularyModel>> getVocabularies(
    String topic,
    String level,
  ) async {
    try {
      // Gửi token nếu có để BE trả về isStarred đúng
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies',
        queryParameters: {'topic': topic, 'level': level},
        options: options,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => VocabularyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi kết nối hoặc tải từ vựng: $e');
    }
  }

  Future<List<String>> getTopics() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies/topics',
      );
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy danh sách chủ đề: $e');
    }
  }

  Future<List<String>> getLevels() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies/levels',
      );
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy danh sách cấp độ: $e');
    }
  }

  Future<UpdateProgressResult> updateProgress(
    String vocabularyId,
    int quality,
  ) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/vocabularies/progress',
        data: {'vocabularyId': vocabularyId, 'quality': quality},
        options: options,
      );
      return UpdateProgressResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi cập nhật tiến độ: $e');
    }
  }

  Future<List<String>> getDueVocabularyIds() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies/due',
        options: options,
      );
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy danh sách từ cần ôn tập: $e');
    }
  }

  Future<List<VocabularyModel>> getDueVocabularies() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies/due/details',
        options: options,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => VocabularyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách từ chi tiết cần ôn tập: $e');
    }
  }

  Future<VocabularyHubStats> getHubStats() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies/hub-stats',
        options: options,
      );
      return VocabularyHubStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy thông tin thống kê: $e');
    }
  }

  Future<List<VocabularyModel>> getStarredVocabularies() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies/starred',
        options: options,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => VocabularyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách từ vựng đã lưu: $e');
    }
  }

  Future<void> toggleStar(String vocabularyId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.post(
        '${AppConstants.baseUrl}/vocabularies/toggle-star/$vocabularyId',
        options: options,
      );
    } catch (e) {
      throw Exception('Lỗi lưu/hủy lưu từ vựng: $e');
    }
  }
}
