import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/reading_part6_model.dart';

class ReadingPart6Repository {
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

  Future<List<ReadingPart6Question>> getQuestions() async {
    try {
      Response response;
      final options = await _getAuthOptions();
      try {
        response = await _dio.get('${AppConstants.baseUrl}/reading/part6/questions', options: options);
      } catch (e) {
        try {
          response = await _dio.get('${AppConstants.baseUrl}/reading/part/6', options: options);
        } catch (e2) {
          try {
            response = await _dio.get('${AppConstants.baseUrl}/reading/questions/6', options: options);
          } catch (e3) {
            response = await _dio.get('${AppConstants.baseUrl}/reading/6/questions', options: options);
          }
        }
      }

      final res = response.data;
      // ignore: avoid_print
      print('ReadingPart6Repository.getQuestions: ${res.runtimeType}');

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
          final firstList = res.values.firstWhere((v) => v is List, orElse: () => null);
          if (firstList is List) list = firstList;
        }
      }

      return list.map((e) => ReadingPart6Question.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('ReadingPart6Repository.getQuestions failed: $e');
      if (e is DioError) {
        // ignore: avoid_print
        print('DioError response: ${e.response?.statusCode} ${e.response?.data}');
      }
      return <ReadingPart6Question>[];
    }
  }

  Future<ReadingPart6SubmitResult> submitAnswers(Map<String, int?> answers) async {
    try {
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
                  'selectedIndex': e.value,
                  'answer': idxToLetter(e.value),
                })
            .toList()
      };

      Response response;
      try {
        response = await _dio.post('${AppConstants.baseUrl}/reading/part6/submit', data: payload);
      } on DioError catch (d) {
        if (d.response?.statusCode == 400) {
          final mapPayload = {'answers': Map.fromEntries(answers.entries.map((e) => MapEntry(e.key, idxToLetter(e.value))))};
          try {
            response = await _dio.post('${AppConstants.baseUrl}/reading/part6/submit', data: mapPayload);
          } on DioError catch (d2) {
            if (d2.response?.statusCode == 400) {
              final altList = answers.entries.map((e) => {'id': e.key, 'answer': idxToLetter(e.value)}).toList();
              response = await _dio.post('${AppConstants.baseUrl}/reading/part6/submit', data: {'answers': altList});
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
          return ReadingPart6SubmitResult.fromJson(Map<String, dynamic>.from(res['data']));
        }
        return ReadingPart6SubmitResult.fromJson(Map<String, dynamic>.from(res));
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
      throw Exception('Lỗi khi gửi đáp án Part6: ${d.message} ${serverMsg.isNotEmpty ? '- server: $serverMsg' : ''}');
    } catch (e) {
      throw Exception('Lỗi khi gửi đáp án Part6: $e');
    }
  }

  Future<int> getCountByPart() async {
    try {
      final options = await _getAuthOptions();
      try {
        final response = await _dio.get('${AppConstants.baseUrl}/reading/part6/count', options: options);
        final data = response.data as Map<String, dynamic>;
        return (data['count'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      try {
        final response = await _dio.get('${AppConstants.baseUrl}/reading/count/6', options: options);
        final data = response.data as Map<String, dynamic>;
        return (data['count'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      try {
        final response = await _dio.get('${AppConstants.baseUrl}/reading/count?part=6', options: options);
        final data = response.data as Map<String, dynamic>;
        return (data['count'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      final list = await getQuestions();
      return list.length;
    } catch (e) {
      throw Exception('Lỗi khi tải số câu part 6: $e');
    }
  }

  Future<List<ReadingPart6HistoryModel>> getHistory() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('${AppConstants.baseUrl}/reading/part6/history', options: options);
      final raw = response.data;
      List<dynamic> dataList = [];
      if (raw is List) {
        dataList = raw;
      } else if (raw is Map) {
        if (raw['data'] is List) dataList = raw['data'];
        else if (raw['items'] is List) dataList = raw['items'];
        else {
          final found = raw.values.firstWhere((v) => v is List, orElse: () => null);
          if (found is List) dataList = found;
        }
      }

      return dataList.map((json) => ReadingPart6HistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sử luyện tập Reading Part 6: $e');
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
      final response = await _dio.post('${AppConstants.baseUrl}/reading/part6/history', data: {
        'correctCount': correctCount,
        'totalCount': totalCount,
        'percent': percent,
        'incorrectQuestionIds': incorrectQuestionIds,
        'selectedAnswers': selectedAnswers,
      }, options: options);
      return response.data['id'] ?? '';
    } catch (e) {
      throw Exception('Lỗi khi lưu lịch sử luyện tập Reading Part 6: $e');
    }
  }
}

