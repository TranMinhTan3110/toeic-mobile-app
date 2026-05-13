import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/reading_part6_model.dart';

class ReadingPart6Repository {
  final Dio _dio = Dio();

  Future<List<ReadingPart6Passage>> getPassages() async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/reading/part6/questions');
      final res = response.data;

      List<dynamic> list = [];
      if (res is List) {
        list = res;
      } else if (res is Map) {
        if (res['data'] is List) list = res['data'];
        else if (res['passages'] is List) list = res['passages'];
        else if (res['items'] is List) list = res['items'];
        else {
          final firstList = res.values.firstWhere((v) => v is List, orElse: () => null);
          if (firstList is List) list = firstList;
        }
      }

      return list.map((e) => ReadingPart6Passage.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải Part6: $e');
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
}
