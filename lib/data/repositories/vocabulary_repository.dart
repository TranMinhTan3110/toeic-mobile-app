import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/vocabulary_model.dart';

class VocabularyRepository {
  final Dio _dio = Dio();

  Future<List<VocabularyModel>> getVocabularies(
    String topic,
    String level,
  ) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies',
        queryParameters: {'topic': topic, 'level': level},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => VocabularyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi kết nối hoặc tải từ vựng: $e');
    }
  }

  Future<List<String>> getTopics() async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/vocabularies/topics');
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy danh sách chủ đề: $e');
    }
  }

  Future<List<String>> getLevels() async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/vocabularies/levels');
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy danh sách cấp độ: $e');
    }
  }
}
