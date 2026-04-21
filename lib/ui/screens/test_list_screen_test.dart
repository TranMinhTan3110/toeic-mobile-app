//dùng để test view TestListScreen và TestDetailScreen
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
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TestListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
