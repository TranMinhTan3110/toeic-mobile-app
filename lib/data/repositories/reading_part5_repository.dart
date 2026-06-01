import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/reading_part5_model.dart';

class ReadingPart5Repository {
  final Dio _dio = Dio();

  Future<List<ReadingPart5Question>> getQuestions() async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/reading/part5/questions');
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
      throw Exception('Lỗi khi tải câu hỏi Part5: $e');
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
}
