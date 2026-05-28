import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/listening_question.dart';
import '../models/speaking_exam_history_model.dart';
import '../models/writing_exam_history_model.dart';

class ExamRepository {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<Options> _getAuthOptions() async {
    final token = await _authService.getIdToken();
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<List<ListeningQuestion>> getQuestionsByExamId(String examId) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/exam/questions/$examId');
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi bài thi $examId: $e');
    }
  }

  Future<List<ListeningGroup>> getGroupsByExamId(String examId) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/exam/groups/$examId');
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningGroup.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhóm câu hỏi bài thi $examId: $e');
    }
  }

  // --- SPEAKING EXAM FLOW ---

  Future<SpeakingExamHistoryModel> submitSpeakingExam({
    required String examSetId,
    required String examTitle,
    required List<Map<String, dynamic>> tasks,
  }) async {
    try {
      final authOptions = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/speaking-exam/history/submit',
        data: {
          'examSetId': examSetId,
          'examTitle': examTitle,
          'tasks': tasks,
        },
        options: authOptions,
      );
      return SpeakingExamHistoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi nộp bài thi Speaking: $e');
    }
  }

  Future<List<SpeakingExamHistoryModel>> getSpeakingExamHistory() async {
    try {
      final authOptions = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/speaking-exam/history',
        options: authOptions,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SpeakingExamHistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử thi Speaking: $e');
    }
  }

  // --- WRITING EXAM FLOW ---

  Future<WritingExamHistoryModel> submitWritingExam({
    required String examSetId,
    required String examTitle,
    required int timeSpent,
    required List<Map<String, dynamic>> tasks,
  }) async {
    try {
      final authOptions = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/writing-exam/history/submit',
        data: {
          'examSetId': examSetId,
          'examTitle': examTitle,
          'timeSpent': timeSpent,
          'tasks': tasks,
        },
        options: authOptions,
      );
      return WritingExamHistoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi nộp bài thi Writing: $e');
    }
  }

  Future<List<WritingExamHistoryModel>> getWritingExamHistory() async {
    try {
      final authOptions = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-exam/history',
        options: authOptions,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WritingExamHistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử thi Writing: $e');
    }
  }
}
