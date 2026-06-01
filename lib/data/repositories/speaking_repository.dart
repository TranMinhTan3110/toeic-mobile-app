import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/speaking_question.dart';
import '../models/speaking_evaluation_model.dart';
import '../models/speaking_history_model.dart';

class SpeakingRepository {
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

  Future<List<SpeakingQuestion>> getQuestionsByTaskNumber(
    int taskNumber, {
    bool? isPractice,
    bool? isExam,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/speaking/task/$taskNumber',
        queryParameters: {
          if (isPractice != null) 'isPractice': isPractice,
          if (isExam != null) 'isExam': isExam,
        },
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SpeakingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Speaking task $taskNumber: $e');
    }
  }

  Future<List<SpeakingQuestion>> getQuestionsByExamSetId(String examSetId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/speaking/exam/$examSetId',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SpeakingQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải đề thi Speaking $examSetId: $e');
    }
  }

  Future<SpeakingEvaluation> evaluateSpeaking({
    required String questionId,
    required String audioPath,
    required String transcript,
    int? subQuestionIndex,
  }) async {
    try {
      final options = await _getAuthOptions();
      
      final Map<String, dynamic> dataMap = {
        'questionId': questionId,
        if (subQuestionIndex != null) 'subQuestionIndex': subQuestionIndex,
        'transcript': transcript,
      };

      if (audioPath.isNotEmpty) {
        if (kIsWeb) {
          final response = await Dio().get<List<int>>(
            audioPath,
            options: Options(responseType: ResponseType.bytes),
          );
          if (response.data != null) {
            dataMap['audio'] = MultipartFile.fromBytes(
              response.data!,
              filename: 'recording.webm',
            );
          }
        } else {
          dataMap['audio'] = await MultipartFile.fromFile(
            audioPath,
            filename: 'recording.m4a',
          );
        }
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dio.post(
        '${AppConstants.baseUrl}/speaking/evaluate',
        data: formData,
        options: options,
      );

      return SpeakingEvaluation.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Lỗi khi chấm điểm bài nói: $e');
    }
  }

  Future<List<SpeakingHistoryModel>> getHistory({String? sessionType}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/speaking/history',
        queryParameters: {
          if (sessionType != null) 'sessionType': sessionType,
        },
        options: options,
      );
      final List<dynamic> data = response.data;
      return data
          .map((json) =>
              SpeakingHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử luyện nói: $e');
    }
  }

  Future<SpeakingHistoryModel> getHistoryById(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/speaking/history/$id',
        options: options,
      );
      return SpeakingHistoryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết lịch sử: $e');
    }
  }

  Future<String> saveHistory({
    required int part,
    required int correctCount,
    required int totalCount,
    required double percent,
    required double score,
    required String feedbackSummary,
    required Map<String, double> criteria,
    required List<SpeakingHistoryAnswerModel> answers,
    String sessionType = 'practice',
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/speaking/history',
        data: {
          'part': part,
          'correctCount': correctCount,
          'totalCount': totalCount,
          'percent': percent,
          'score': score,
          'feedbackSummary': feedbackSummary,
          'criteria': criteria,
          'sessionType': sessionType,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
        options: options,
      );
      return (response.data as Map<String, dynamic>)['id']?.toString() ?? '';
    } catch (e) {
      throw Exception('Lỗi khi lưu lịch sử luyện nói: $e');
    }
  }
}
