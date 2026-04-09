import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vocabulary_provider.dart';
import 'ui/screens/Vocabulary/vocabulary_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', 
      ),
      home: const VocabularyScreen(),
    );
  }
}
