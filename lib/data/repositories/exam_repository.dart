import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/listening_question.dart';

class ExamRepository {
  final Dio _dio = Dio();

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
}
