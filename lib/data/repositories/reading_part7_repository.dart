import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/reading_part7_model.dart';

class ReadingPart7Repository {
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

  Future<List<ReadingPart7Question>> getQuestions() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/reading/part7/questions',
      );
      final res = response.data;

      List<dynamic> items = [];
      if (res is List) {
        items = res;
      } else if (res is Map) {
        if (res['data'] is List)
          items = res['data'];
        else if (res['questions'] is List)
          items = res['questions'];
        else if (res['passages'] is List) {
          // flatten passages -> questions, inject passage text into each question
          final List<ReadingPart7Question> out = [];
          for (var p in (res['passages'] as List)) {
            if (p is Map) {
              final passageText =
                  (p['passageText'] ?? p['passage'] ?? p['text'] ?? '')
                      .toString();
              final qraw = p['questions'] is List
                  ? p['questions'] as List
                  : (p['items'] is List ? p['items'] as List : []);
              for (var q in qraw) {
                if (q is Map) {
                  final merged = Map<String, dynamic>.from(q);
                  if (!merged.containsKey('passage') && passageText.isNotEmpty)
                    merged['passage'] = passageText;
                  // propagate group-level passage translation into each question if present
                  final pt =
                      (p['passageTranslation'] ??
                      p['passageTranslationVi'] ??
                      p['passage_translation'] ??
                      p['passage_translation_vi']);
                  if (pt != null && pt.toString().isNotEmpty) {
                    if (!merged.containsKey('passageTranslation'))
                      merged['passageTranslation'] = pt;
                    if (!merged.containsKey('passage_translation'))
                      merged['passage_translation'] = pt;
                    if (!merged.containsKey('passage_translation_vi'))
                      merged['passage_translation_vi'] = pt;
                  }
                  out.add(ReadingPart7Question.fromJson(merged));
                }
              }
            }
          }
          return out;
        } else if (res['items'] is List)
          items = res['items'];
        else {
          final firstList = res.values.firstWhere(
            (v) => v is List,
            orElse: () => null,
          );
          if (firstList is List) items = firstList;
        }
      }

      // If items contain passages, detect and flatten
      if (items.isNotEmpty &&
          items.first is Map &&
          (items.first as Map).containsKey('questions')) {
        final List<ReadingPart7Question> out = [];
        for (var e in items) {
          if (e is Map) {
            final passageText =
                (e['passageText'] ?? e['passage'] ?? e['text'] ?? '')
                    .toString();
            final qraw = e['questions'] is List
                ? e['questions'] as List
                : (e['items'] is List ? e['items'] as List : []);
            for (var q in qraw) {
              if (q is Map) {
                final merged = Map<String, dynamic>.from(q);
                if (!merged.containsKey('passage') && passageText.isNotEmpty)
                  merged['passage'] = passageText;
                final pt =
                    (e['passageTranslation'] ??
                    e['passageTranslationVi'] ??
                    e['passage_translation'] ??
                    e['passage_translation_vi']);
                if (pt != null && pt.toString().isNotEmpty) {
                  if (!merged.containsKey('passageTranslation'))
                    merged['passageTranslation'] = pt;
                  if (!merged.containsKey('passage_translation'))
                    merged['passage_translation'] = pt;
                  if (!merged.containsKey('passage_translation_vi'))
                    merged['passage_translation_vi'] = pt;
                }
                out.add(ReadingPart7Question.fromJson(merged));
              }
            }
          }
        }
        return out;
      }

      return items
          .map((e) => ReadingPart7Question.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<ReadingPart7SubmitResult> submitAnswers(
    Map<String, int?> answers,
  ) async {
    try {
      String idxToLetter(int? idx) {
        if (idx == null) return '';
        const letters = ['A', 'B', 'C', 'D'];
        if (idx < 0 || idx >= letters.length) return '';
        return letters[idx];
      }

      // Try multiple payload formats to be resilient to different backends
      final payloadList = answers.entries
          .map(
            (e) => {
              'questionId': e.key,
              'answer': idxToLetter(e.value),
              'selectedIndex': e.value,
            },
          )
          .toList();
      final payloadMap = Map.fromEntries(
        answers.entries.map((e) => MapEntry(e.key, idxToLetter(e.value))),
      );

      Response response;
      try {
        response = await _dio.post(
          '${AppConstants.baseUrl}/reading/part7/submit',
          data: {'answers': payloadList},
        );
      } on DioError catch (d) {
        if (d.response?.statusCode == 400) {
          try {
            response = await _dio.post(
              '${AppConstants.baseUrl}/reading/part7/submit',
              data: {'answers': payloadMap},
            );
          } on DioError catch (d2) {
            if (d2.response?.statusCode == 400) {
              response = await _dio.post(
                '${AppConstants.baseUrl}/reading/part7/submit',
                data: jsonEncode({'answers': payloadMap}),
              );
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
        if (res['data'] is Map)
          return ReadingPart7SubmitResult.fromJson(
            Map<String, dynamic>.from(res['data']),
          );
        return ReadingPart7SubmitResult.fromJson(
          Map<String, dynamic>.from(res),
        );
      }
      return ReadingPart7SubmitResult(
        correct: 0,
        total: answers.length,
        details: [],
      );
    } catch (e) {
      return ReadingPart7SubmitResult(
        correct: 0,
        total: answers.length,
        details: [],
      );
    }
  }

  Future<int> getCountByPart() async {
    try {
      final res = await _dio.get('${AppConstants.baseUrl}/reading/part7/count');
      final data = res.data;
      if (data is Map && data['count'] != null)
        return (data['count'] as num).toInt();
      if (data is num) return data.toInt();
    } catch (_) {}
    return 0;
  }

  Future<List<ReadingPart7HistoryModel>> getHistory() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/reading/part7/history',
        options: options,
      );
      final raw = response.data;
      List<dynamic> dataList = [];
      if (raw is List) {
        dataList = raw;
      } else if (raw is Map) {
        if (raw['data'] is List)
          dataList = raw['data'];
        else if (raw['items'] is List)
          dataList = raw['items'];
        else {
          final found = raw.values.firstWhere(
            (v) => v is List,
            orElse: () => null,
          );
          if (found is List) dataList = found;
        }
      }

      return dataList
          .map((json) => ReadingPart7HistoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử luyện tập Reading Part 7: $e');
    }
  }

  Future<String> saveHistory({
    required int correctCount,
    required int totalCount,
    required double percent,
    required List<String> incorrectQuestionIds,
    required Map<String, String> selectedAnswers,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '${AppConstants.baseUrl}/reading/part7/history',
        data: {
          'correctCount': correctCount,
          'totalCount': totalCount,
          'percent': percent,
          'incorrectQuestionIds': incorrectQuestionIds,
          'selectedAnswers': selectedAnswers,
        },
        options: options,
      );
      return response.data['id'] ?? '';
    } catch (e) {
      throw Exception('Lỗi khi lưu lịch sử luyện tập Reading Part 7: $e');
    }
  }
}
