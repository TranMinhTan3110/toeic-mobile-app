import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

class AiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> analyzeSentence(String sentence, String word, String situation) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/Ai/analyze',
        data: {
          'sentence': sentence,
          'word': word,
          'situation': situation,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to analyze sentence: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error connecting to AI service: $e');
    }
  }

  Future<Map<String, dynamic>> getScenario(String word, String meaning) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/Ai/scenario',
        queryParameters: {'word': word, 'meaning': meaning},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get scenario: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error connecting to AI service: $e');
    }
  }
}
