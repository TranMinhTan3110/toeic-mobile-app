import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();

  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0); // Mức cao nhất là 1.0
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    print('=== ĐANG PHÁT ÂM: $text ===');
    try {
      await _flutterTts.setVolume(1.0); // Cài lại volume mỗi lần speak cho chắc
      var result = await _flutterTts.speak(text);
      if (result == 1) {
        print('=== PHÁT ÂM THÀNH CÔNG ===');
      } else {
        print('=== PHÁT ÂM THẤT BẠI (Code: $result) ===');
      }
    } catch (e) {
      print('=== LỖI TTS: $e ===');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
