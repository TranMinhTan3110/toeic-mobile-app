import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get baseUrl {
    // 1. Cho phép mỗi máy override riêng theo platform trong file .env local.
    final platformEnvUrl = _platformEnvUrl;
    if (platformEnvUrl != null && platformEnvUrl.isNotEmpty) {
      return platformEnvUrl;
    }

    // 2. Ưu tiên lấy từ file .env nếu có (Dành cho máy thật cắm cáp hoặc custom IP)
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // 3. Nếu không có file .env thì tự nhận diện theo thiết bị giả lập
    if (kIsWeb) return 'http://localhost:5133/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5133/api';
    if (Platform.isIOS) return 'http://127.0.0.1:5133/api';

    // 4. Mặc định dự phòng
    return 'http://192.168.1.7:5133/api';
  }

  static String? get _platformEnvUrl {
    if (kIsWeb) return dotenv.env['API_BASE_URL_WEB'];
    if (Platform.isAndroid) return dotenv.env['API_BASE_URL_ANDROID'];
    if (Platform.isIOS) return dotenv.env['API_BASE_URL_IOS'];
    if (Platform.isWindows) return dotenv.env['API_BASE_URL_WINDOWS'];
    if (Platform.isMacOS) return dotenv.env['API_BASE_URL_MACOS'];
    if (Platform.isLinux) return dotenv.env['API_BASE_URL_LINUX'];
    return null;
  }
}
