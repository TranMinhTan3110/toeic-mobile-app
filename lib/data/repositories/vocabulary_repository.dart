import 'package:dio/dio.dart';
import '../models/vocabulary_model.dart';

class VocabularyRepository {
  final Dio _dio = Dio();

  // Dùng cho máy ảo Android Emulator
  final String baseUrl = 'http://10.0.2.2:5133/api'; 

  Future<List<VocabularyModel>> getVocabularies(
    String topic,
    String level,
  ) async {
    try {
      // Gọi API thật tới Backend để lấy từ vựng theo chủ đề và mục tiêu điểm
      final response = await _dio.get(
        '$baseUrl/Vocabulary',
        queryParameters: {'topic': topic, 'level': level},
      );

      // Nếu Backend trả về dạng list object JSON thì Dio tự hiểu là List<dynamic>
      print('=== DỮ LIỆU TỪ BE ===');
      print(response.data);
      final List<dynamic> data = response.data;

      return data.map((json) => VocabularyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi kết nối hoặc tải từ vựng từ BE: $e');
      
    }
  }
}
