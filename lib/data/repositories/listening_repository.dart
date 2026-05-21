import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/listening_question.dart';

class ListeningRepository {
  final Dio _dio = Dio();

  Future<List<ListeningQuestion>> getQuestionsByPart(int part) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/listening/part/$part');
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningQuestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải câu hỏi Listening part $part: $e');
    }
  }

  Future<List<ListeningGroup>> getGroupsByPart(int part) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/listening/groups/$part');
      final List<dynamic> data = response.data;
      return data.map((json) => ListeningGroup.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhóm câu hỏi Listening part $part: $e');
    }
  }
}
