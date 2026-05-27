import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/writing_history_item.dart';
import '../models/writing_question.dart';

class WritingRepository {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<Options> _getAuthOptions() async {
    final token = await _authService.getIdToken();
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  /// Get all writing questions
  Future<List<WritingQuestion>> getAll() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải tất cả câu hỏi Writing: $e');
    }
  }

  /// Get writing question by ID
  Future<WritingQuestion> getById(String id) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/$id',
      );
      return WritingQuestion.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Writing ID $id: $e');
    }
  }

  /// Get questions by task type (write_sentence, respond_email, opinion_essay)
  Future<List<WritingQuestion>> getByTaskType(String taskType) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/by-type/$taskType',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Writing task type $taskType: $e');
    }
  }

  /// Get questions by task number (1-8)
  Future<List<WritingQuestion>> getByTaskNumber(int taskNumber) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/by-number/$taskNumber',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Writing task $taskNumber: $e');
    }
  }

  /// Get questions by difficulty (easy, medium, hard)
  Future<List<WritingQuestion>> getByDifficulty(String difficulty) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/by-difficulty/$difficulty',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Writing độ khó $difficulty: $e');
    }
  }

  /// Get practice questions only
  Future<List<WritingQuestion>> getPracticeQuestions() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/practice',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Writing practice: $e');
    }
  }

  /// Get practice questions by task type
  Future<List<WritingQuestion>> getPracticeByTaskType(String taskType) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/by-type/$taskType/practice',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
        'Lỗi khi tải câu hỏi Writing practice task type $taskType: $e',
      );
    }
  }

  /// Get exam questions by task type
  Future<List<WritingQuestion>> getExamByTaskType(String taskType) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/by-type/$taskType/exam',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
        'Lỗi khi tải câu hỏi Writing exam task type $taskType: $e',
      );
    }
  }

  /// Get available task types
  Future<List<String>> getAvailableTaskTypes() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/types',
      );
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách task types: $e');
    }
  }

  Future<List<WritingHistoryItem>> getHistory({String? sessionType}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing/history',
        queryParameters: {if (sessionType != null) 'sessionType': sessionType},
        options: options,
      );
      final List<dynamic> data = response.data;
      return data
          .map(
            (json) => WritingHistoryItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử Writing: $e');
    }
  }

  Future<WritingHistoryItem> getHistoryById(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing/history/$id',
        options: options,
      );
      return WritingHistoryItem.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết lịch sử Writing: $e');
    }
  }

  Future<String> saveSubmission({
    String? questionId,
    String sessionType = 'practice',
    String? userAnswer,
    List<String>? questionIds,
    Map<String, String>? answers,
    int? questionCount,
    int? taskNumber,
    String? taskType,
    int? wordCount,
    int? timeUsed,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/writing/history',
        data: {
          if (questionId != null) 'questionId': questionId,
          'sessionType': sessionType,
          if (userAnswer != null) 'userAnswer': userAnswer,
          if (questionIds != null) 'questionIds': questionIds,
          if (answers != null) 'answers': answers,
          if (questionCount != null) 'questionCount': questionCount,
          if (taskNumber != null) 'taskNumber': taskNumber,
          if (taskType != null) 'taskType': taskType,
          if (wordCount != null) 'wordCount': wordCount,
          if (timeUsed != null) 'timeUsed': timeUsed,
        },
        options: options,
      );
      return (response.data as Map<String, dynamic>)['id']?.toString() ?? '';
    } catch (e) {
      throw Exception('Lỗi khi lưu lịch sử Writing: $e');
    }
  }
}
