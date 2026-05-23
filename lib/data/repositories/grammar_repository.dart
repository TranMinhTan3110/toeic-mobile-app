import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/grammar_model.dart';
import '../models/listening_question.dart';

class GrammarRepository {
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

  /// GET /api/grammar/topics
  Future<List<GrammarTopic>> getGrammarTopics() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/grammar/topics',
        options: options,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => GrammarTopic.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách chủ đề ngữ pháp: $e');
    }
  }

  /// GET /api/grammar/lessons/{topicId}
  Future<GrammarLesson> getGrammarLesson(String topicId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/grammar/lessons/$topicId',
        options: options,
      );
      return GrammarLesson.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải bài học lý thuyết cho $topicId: $e');
    }
  }

  /// GET /api/grammar/exercises/{topicId}
  Future<List<ListeningQuestion>> getGrammarExercises(String topicId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/grammar/exercises/$topicId',
        options: options,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải bài tập thực hành cho $topicId: $e');
    }
  }
}
