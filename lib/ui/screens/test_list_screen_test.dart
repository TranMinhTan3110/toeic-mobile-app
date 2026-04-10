import 'package:flutter/material.dart';
import 'exam/test_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC App Test',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Set màu chủ đạo cho giống thiết kế
        scaffoldBackgroundColor: Colors.white,
      ),
      // Set màn hình danh sách đề thi làm màn hình khởi động
      home: const TestListScreen(),
      // Tắt cái dải băng chữ DEBUG đỏ đỏ ở góc phải màn hình cho đẹp
      debugShowCheckedModeBanner: false,
    );
  }
}
