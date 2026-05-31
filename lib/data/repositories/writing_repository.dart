import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/writing_history_item.dart';
import '../models/writing_question.dart';
import '../models/writing_evaluation_model.dart';

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

  Future<WritingEvaluation> evaluateWriting({
    required String questionId,
    required String userAnswer,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/writing/evaluate',
        data: {
          'questionId': questionId,
          'userAnswer': userAnswer,
        },
        options: options,
      );
      return WritingEvaluation.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Lỗi khi chấm điểm bài viết: $e');
    }
  }

  Future<List<WritingHistoryItem>> getHistory({String? sessionType}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing/history',
        queryParameters: {
          if (sessionType != null && sessionType.isNotEmpty)
            'sessionType': sessionType,
        },
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

  /// Save a single submission (for individual question saves)
  Future<String?> saveSubmission({
    required String questionId,
    String sessionType = 'practice',
    required String userAnswer,
    int? taskNumber,
    String? taskType,
    int? wordCount,
    int? timeUsed,
    int? aiScore,
    WritingAiFeedback? aiFeedback,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/writing/history',
        data: {
          'questionId': questionId,
          'taskNumber': taskNumber,
          'taskType': taskType,
          'sessionType': sessionType,
          'userAnswer': userAnswer,
          'wordCount': wordCount,
          'timeUsed': timeUsed,
          'aiScore': aiScore,
          'aiFeedback': aiFeedback?.toJson(),
        },
        options: options,
      );
      return (response.data as Map<String, dynamic>)['id']?.toString();
    } on DioException catch (e) {
      throw Exception(
        'Lỗi khi lưu lịch sử Writing: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi khi lưu lịch sử Writing: $e');
    }
  }

  /// Save a complete session with multiple answers (only save once when session is completed)
  Future<String?> saveSession({
    String? historyId,
    required List<String> questionIds,
    required Map<String, String> answers,
    required String sessionType,
    int? taskNumber,
    String? taskType,
    int? questionCount,
    int? correctCount,
    int? timeSpent,
    List<String>? incorrectIds,
    int? aiScore,
    WritingAiFeedback? aiFeedback,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/writing/session',
        data: {
          'id': historyId,
          'questionIds': questionIds,
          'answers': answers,
          'taskNumber': taskNumber,
          'taskType': taskType,
          'sessionType': sessionType,
          'questionCount': questionCount,
          'correctCount': correctCount,
          'timeSpent': timeSpent,
          'incorrectIds': incorrectIds,
          'aiScore': aiScore,
          'aiFeedback': aiFeedback?.toJson(),
        },
        options: options,
      );
      return (response.data as Map<String, dynamic>)['id']?.toString();
    } on DioException catch (e) {
      throw Exception(
        'Lỗi khi lưu phiên Writing: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi khi lưu phiên Writing: $e');
    }
  }
}
