import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/listening_question.dart';
import '../models/listening_history_model.dart';

class ListeningRepository {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<Options> _getAuthOptions() async {
    final token = await _authService.getIdToken();
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<List<ListeningQuestion>> getQuestionsByPart(int part) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/listening/part/$part');
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Listening part $part: $e');
    }
  }

  Future<List<ListeningGroup>> getGroupsByPart(int part) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/listening/groups/$part');
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningGroup.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhóm câu hỏi Listening part $part: $e');
    }
  }

  /// Gọi endpoint count — chỉ tốn 1 Firestore read, cực nhanh.
  /// Dùng cho DetailScreen để hiển thị số câu mà không load toàn bộ data.
  Future<int> getCountByPart(int part) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/listening/count/$part');
      final data = response.data as Map<String, dynamic>;
      return (data['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw Exception('Lỗi khi tải số câu part $part: $e');
    }
  }

  // --- Lịch sử ôn luyện Nghe ---

  Future<List<ListeningHistoryModel>> getHistory() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/listening/history',
        options: options,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningHistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử luyện tập nghe: $e');
    }
  }

  Future<String> saveHistory({
    required int part,
    required int correctCount,
    required int totalCount,
    required double percent,
    required List<String> incorrectQuestionIds,
    required Map<String, String> selectedAnswers,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/listening/history',
        data: {
          'part': part,
          'correctCount': correctCount,
          'totalCount': totalCount,
          'percent': percent,
          'incorrectQuestionIds': incorrectQuestionIds,
          'selectedAnswers': selectedAnswers,
        },
        options: options,
      );
      return response.data['id'] ?? '';
    } catch (e) {
      throw Exception('Lỗi khi lưu lịch sử luyện tập nghe: $e');
    }
  }
}

