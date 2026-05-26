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

  /// Gọi endpoint count — chỉ tốn 1 Firestore read, cực nhanh.
  /// Dùng cho DetailScreen để hiển thị số câu mà không load toàn bộ data.
  Future<int> getCountByPart(int part) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/listening/count/$part');
      final data = response.data as Map<String, dynamic>;
      return (data['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw Exception('Lỗi khi tải số câu part $part: $e');
    }
  }
}
