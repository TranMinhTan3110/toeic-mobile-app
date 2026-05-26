import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/speaking_question.dart';
import '../models/speaking_evaluation_model.dart';

class SpeakingRepository {
  final Dio _dio = Dio();

  Future<List<SpeakingQuestion>> getQuestionsByTaskNumber(
    int taskNumber,
  ) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/speaking/task/$taskNumber',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SpeakingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Speaking task $taskNumber: $e');
    }
  }

  Future<SpeakingEvaluation> evaluateSpeaking({
    required String questionId,
    required String audioPath,
    int? subQuestionIndex,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "questionId": questionId,
        "subQuestionIndex": ?subQuestionIndex,
        "audio": await MultipartFile.fromFile(
          audioPath,
          filename: "recording.m4a",
        ),
      });

      final response = await _dio.post(
        '${AppConstants.baseUrl}/speaking/evaluate',
        data: formData,
      );

      return SpeakingEvaluation.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi chấm điểm bài nói: $e');
    }
  }
}
