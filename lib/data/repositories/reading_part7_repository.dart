import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/reading_part7_model.dart';

class ReadingPart7Repository {
  final Dio _dio = Dio();

  Future<List<ReadingPart7Question>> getQuestions() async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/reading/part7/questions');
      final res = response.data;

      List<dynamic> items = [];
      if (res is List) {
        items = res;
      } else if (res is Map) {
        if (res['data'] is List) items = res['data'];
        else if (res['questions'] is List) items = res['questions'];
        else if (res['passages'] is List) {
          // flatten passages -> questions
          final passages = (res['passages'] as List).map((p) => ReadingPart7Passage.fromJson(p as Map<String, dynamic>)).toList();
          return passages.expand((p) => p.questions).toList();
        } else if (res['items'] is List) items = res['items'];
        else {
          final firstList = res.values.firstWhere((v) => v is List, orElse: () => null);
          if (firstList is List) items = firstList;
        }
      }

      // If items contain passages, detect and flatten
      if (items.isNotEmpty && items.first is Map && (items.first as Map).containsKey('questions')) {
        final passages = items.map((e) => ReadingPart7Passage.fromJson(e as Map<String, dynamic>)).toList();
        return passages.expand((p) => p.questions).toList();
      }

      return items.map((e) => ReadingPart7Question.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ReadingPart7SubmitResult> submitAnswers(Map<String, int?> answers) async {
    try {
      String idxToLetter(int? idx) {
        if (idx == null) return '';
        const letters = ['A', 'B', 'C', 'D'];
        if (idx < 0 || idx >= letters.length) return '';
        return letters[idx];
      }

      // Try multiple payload formats to be resilient to different backends
      final payloadList = answers.entries.map((e) => {'questionId': e.key, 'answer': idxToLetter(e.value), 'selectedIndex': e.value}).toList();
      final payloadMap = Map.fromEntries(answers.entries.map((e) => MapEntry(e.key, idxToLetter(e.value))));

      Response response;
      try {
        response = await _dio.post('${AppConstants.baseUrl}/reading/part7/submit', data: {'answers': payloadList});
      } on DioError catch (d) {
        if (d.response?.statusCode == 400) {
          try {
            response = await _dio.post('${AppConstants.baseUrl}/reading/part7/submit', data: {'answers': payloadMap});
          } on DioError catch (d2) {
            if (d2.response?.statusCode == 400) {
              response = await _dio.post('${AppConstants.baseUrl}/reading/part7/submit', data: jsonEncode({'answers': payloadMap}));
            } else {
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }

      final res = response.data;
      if (res is Map<String, dynamic>) {
        if (res['data'] is Map) return ReadingPart7SubmitResult.fromJson(Map<String, dynamic>.from(res['data']));
        return ReadingPart7SubmitResult.fromJson(Map<String, dynamic>.from(res));
      }
      return ReadingPart7SubmitResult(correct: 0, total: answers.length, details: []);
    } catch (e) {
      return ReadingPart7SubmitResult(correct: 0, total: answers.length, details: []);
    }
  }

  Future<int> getCountByPart() async {
    try {
      final res = await _dio.get('${AppConstants.baseUrl}/reading/part7/count');
      final data = res.data;
      if (data is Map && data['count'] != null) return (data['count'] as num).toInt();
      if (data is num) return data.toInt();
    } catch (_) {}
    return 0;
  }

  Future<List<ReadingPart7HistoryModel>> getHistory() async {
    try {
      final res = await _dio.get('${AppConstants.baseUrl}/reading/part7/history');
      final data = res.data;
      List items = [];
      if (data is List) items = data;
      else if (data is Map && data['data'] is List) items = data['data'];
      return items.map((e) => ReadingPart7HistoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> saveHistory({required int correctCount, required int totalCount, required double percent, required List<String> incorrectQuestionIds, required Map<String, String> selectedAnswers}) async {
    final payload = {
      'correctCount': correctCount,
      'totalCount': totalCount,
      'percent': percent,
      'incorrectQuestionIds': incorrectQuestionIds,
      'selectedAnswers': selectedAnswers,
    };
    try {
      final res = await _dio.post('${AppConstants.baseUrl}/reading/part7/history', data: jsonEncode(payload));
      if (res.data is Map && res.data['id'] != null) return res.data['id'].toString();
    } catch (_) {}
    return '';
  }
}
