import 'package:flutter/material.dart';

class SeeMoreScreen extends StatelessWidget {
  final String title;

  const SeeMoreScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF4DB6AC),
      ),
      body: Center(
        child: Text('Chưa làm', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
