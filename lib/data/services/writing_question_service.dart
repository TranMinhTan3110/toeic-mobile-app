import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/writing_question_model.dart';

class WritingQuestionService {
  final Dio _dio;

  WritingQuestionService(this._dio);

  String get _baseUrl => '${AppConstants.baseUrl}/writing-questions';

  // Lấy tất cả writing questions
  Future<List<WritingQuestion>> getAllQuestions() async {
    try {
      print('[WritingQuestionService] GET $_baseUrl');
      final response = await _dio.get(_baseUrl);
      final List<dynamic> data = response.data;
      print('[WritingQuestionService] Received ${data.length} questions');
      return data.map((q) => WritingQuestion.fromJson(q)).toList();
    } catch (e) {
      print('[WritingQuestionService] Error: $e');
      rethrow;
    }
  }

  // Lấy question theo ID
  Future<WritingQuestion> getQuestionById(String id) async {
    try {
      print('[WritingQuestionService] GET $_baseUrl/$id');
      final response = await _dio.get('$_baseUrl/$id');
      return WritingQuestion.fromJson(response.data);
    } catch (e) {
      print('[WritingQuestionService] Error: $e');
      rethrow;
    }
  }

  // Lấy theo task type (write_sentence, respond_email, opinion_essay)
  Future<List<WritingQuestion>> getByTaskType(String taskType) async {
    try {
      final url = '$_baseUrl/by-type/$taskType';
      print('[WritingQuestionService] GET $url');
      final response = await _dio.get(url);
      final List<dynamic> data = response.data ?? [];
      print('[WritingQuestionService] Received ${data.length} questions for type: $taskType');
      return data.map((q) => WritingQuestion.fromJson(q)).toList();
    } catch (e) {
      print('[WritingQuestionService] Error: $e');
      rethrow;
    }
  }

  // Lấy theo task number (1-8)
  Future<List<WritingQuestion>> getByTaskNumber(int taskNumber) async {
    try {
      final url = '$_baseUrl/by-number/$taskNumber';
      print('[WritingQuestionService] GET $url');
      final response = await _dio.get(url);
      final List<dynamic> data = response.data ?? [];
      print('[WritingQuestionService] Received ${data.length} questions for number: $taskNumber');
      return data.map((q) => WritingQuestion.fromJson(q)).toList();
    } catch (e) {
      print('[WritingQuestionService] Error: $e');
      rethrow;
    }
  }

  // Lấy theo difficulty
  Future<List<WritingQuestion>> getByDifficulty(String difficulty) async {
    try {
      final url = '$_baseUrl/by-difficulty/$difficulty';
      print('[WritingQuestionService] GET $url');
      final response = await _dio.get(url);
      final List<dynamic> data = response.data ?? [];
      print('[WritingQuestionService] Received ${data.length} questions for difficulty: $difficulty');
      return data.map((q) => WritingQuestion.fromJson(q)).toList();
    } catch (e) {
      print('[WritingQuestionService] Error: $e');
      rethrow;
    }
  }

  // Lấy practice questions
  Future<List<WritingQuestion>> getPracticeQuestions() async {
    try {
      final url = '$_baseUrl/practice';
      print('[WritingQuestionService] GET $url');
      final response = await _dio.get(url);
      final List<dynamic> data = response.data ?? [];
      print('[WritingQuestionService] Received ${data.length} practice questions');
      return data.map((q) => WritingQuestion.fromJson(q)).toList();
    } catch (e) {
      print('[WritingQuestionService] Error: $e');
      rethrow;
    }
  }

  // Lấy danh sách task types
  Future<List<String>> getAvailableTaskTypes() async {
    try {
      final url = '$_baseUrl/types';
      print('[WritingQuestionService] GET $url');
      final response = await _dio.get(url);
      final List<String> types = List<String>.from(response.data ?? []);
      print('[WritingQuestionService] Available task types: $types');
      return types;
    } catch (e) {
      print('[WritingQuestionService] Error: $e');
      rethrow;
    }
  }
}
