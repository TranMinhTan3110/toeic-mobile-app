import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get baseUrl {
    // 1. Ưu tiên lấy từ file .env nếu có (Dành cho máy thật cắm cáp hoặc custom IP)
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. Nếu không có file .env thì tự nhận diện theo thiết bị giả lập
    if (kIsWeb) return 'http://localhost:5133/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5133/api';
    if (Platform.isIOS) return 'http://127.0.0.1:5133/api';

    // 3. Mặc định dự phòng
    return 'http://192.168.1.7:5133/api';
  }
}
