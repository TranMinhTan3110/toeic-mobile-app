import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  double _currentRate = 0.5;

  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_currentRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> setRate(double rate) async {
    _currentRate = rate;
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    print('=== ĐANG PHÁT ÂM: $text (Tốc độ: $_currentRate) ===');
    try {
      await _flutterTts.setVolume(1.0);
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
