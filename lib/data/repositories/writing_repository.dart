import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/writing_question.dart';

class WritingRepository {
  final Dio _dio = Dio();

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

  /// Get writing questions by exam set ID
  Future<List<WritingQuestion>> getQuestionsByExamSetId(String examSetId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/exam/$examSetId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Writing của đề thi $examSetId: $e');
    }
  }
}
