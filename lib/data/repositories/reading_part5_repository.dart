import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/reading_part5_model.dart';

class ReadingPart5Repository {
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

  Future<List<ReadingPart5Question>> getQuestions() async {
    try {
      // Try multiple common endpoint shapes to be resilient to backend changes
      Response response;
      try {
        response = await _dio.get('${AppConstants.baseUrl}/reading/part5/questions');
      } catch (e) {
        try {
          response = await _dio.get('${AppConstants.baseUrl}/reading/part/5');
        } catch (e2) {
          try {
            response = await _dio.get('${AppConstants.baseUrl}/reading/questions/5');
          } catch (e3) {
            // Last resort: try plural base reading endpoint
            response = await _dio.get('${AppConstants.baseUrl}/reading/5/questions');
          }
        }
      }

      final res = response.data;
      // Debug log
      // print the raw response for easier debugging
      // ignore: avoid_print
      print('ReadingPart5Repository.getQuestions: ${res.runtimeType}');

      List<dynamic> list = [];
      if (res is List) {
        list = res;
      } else if (res is Map) {
        if (res['data'] is List) {
          list = res['data'];
        } else if (res['questions'] is List) {
          list = res['questions'];
        } else if (res['items'] is List) {
          list = res['items'];
        } else {
          // maybe the API wraps result under another key, try to find the first list
          final firstList = res.values.firstWhere((v) => v is List, orElse: () => null);
          if (firstList is List) list = firstList;
        }
      }

      return list.map((e) => ReadingPart5Question.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // If any endpoint returns a 4xx/5xx, avoid throwing during preload —
      // return an empty list so the app can continue and show fallback UI.
      // Log the error for debugging.
      // ignore: avoid_print
      print('ReadingPart5Repository.getQuestions failed: $e');
      return <ReadingPart5Question>[];
    }
  }

  Future<ReadingPart5SubmitResult> submitAnswers(Map<String, int?> answers) async {
    try {
      // Convert selected index to letter A/B/C/D which many backends expect
      String idxToLetter(int? idx) {
        if (idx == null) return '';
        const letters = ['A', 'B', 'C', 'D'];
        if (idx < 0 || idx >= letters.length) return '';
        return letters[idx];
      }

      final payload = {
        'answers': answers.entries
            .map((e) => {
                  'questionId': e.key,
                  // send both forms to be safe
                  'selectedIndex': e.value,
                  'answer': idxToLetter(e.value),
                })
            .toList()
      };

      Response response;
      try {
        response = await _dio.post('${AppConstants.baseUrl}/reading/part5/submit', data: payload);
      } on DioError catch (d) {
        // If server rejects this shape, try an alternative payload shapes
        if (d.response?.statusCode == 400) {
          // try map form { answers: {id: 'A', ...} }
          final mapPayload = {'answers': Map.fromEntries(answers.entries.map((e) => MapEntry(e.key, idxToLetter(e.value))))};
          try {
            response = await _dio.post('${AppConstants.baseUrl}/reading/part5/submit', data: mapPayload);
          } on DioError catch (d2) {
            if (d2.response?.statusCode == 400) {
              // try list with id/answer keys
              final altList = answers.entries.map((e) => {'id': e.key, 'answer': idxToLetter(e.value)}).toList();
              response = await _dio.post('${AppConstants.baseUrl}/reading/part5/submit', data: {'answers': altList});
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
        if (res['data'] is Map) {
          return ReadingPart5SubmitResult.fromJson(Map<String, dynamic>.from(res['data']));
        }
        return ReadingPart5SubmitResult.fromJson(Map<String, dynamic>.from(res));
      }
      throw Exception('Unexpected submit response format');
    } on DioError catch (d) {
      final resp = d.response?.data;
      String serverMsg = '';
      try {
        serverMsg = resp is Map && resp['message'] != null ? resp['message'].toString() : resp?.toString() ?? '';
      } catch (_) {
        serverMsg = resp?.toString() ?? '';
      }
      throw Exception('Lỗi khi gửi đáp án Part5: ${d.message} ${serverMsg.isNotEmpty ? '- server: $serverMsg' : ''}');
    } catch (e) {
      throw Exception('Lỗi khi gửi đáp án Part5: $e');
    }
  }

  Future<int> getCountByPart() async {
    try {
      // Try several possible count endpoints used by backend
      try {
        final response = await _dio.get('${AppConstants.baseUrl}/reading/part5/count');
        final data = response.data as Map<String, dynamic>;
        return (data['count'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      try {
        final response = await _dio.get('${AppConstants.baseUrl}/reading/count/5');
        final data = response.data as Map<String, dynamic>;
        return (data['count'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      try {
        final response = await _dio.get('${AppConstants.baseUrl}/reading/count?part=5');
        final data = response.data as Map<String, dynamic>;
        return (data['count'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      // Fallback: fetch full questions and return length
      final list = await getQuestions();
      return list.length;
    } catch (e) {
      throw Exception('Lỗi khi tải số câu part 5: $e');
    }
  }

  Future<List<ReadingPart5HistoryModel>> getHistory() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/reading/part5/history',
        options: options,
      );
      final raw = response.data;
      List<dynamic> dataList = [];
      if (raw is List) {
        dataList = raw;
      } else if (raw is Map) {
        if (raw['data'] is List) dataList = raw['data'];
        else if (raw['items'] is List) dataList = raw['items'];
        else {
          // try to find first list value
          final found = raw.values.firstWhere((v) => v is List, orElse: () => null);
          if (found is List) dataList = found;
        }
      }

      return dataList.map((json) => ReadingPart5HistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử luyện tập Reading Part 5: $e');
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
        '${AppConstants.baseUrl}/reading/part5/history',
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
      throw Exception('Lỗi khi lưu lịch sử luyện tập Reading Part 5: $e');
    }
  }
}
