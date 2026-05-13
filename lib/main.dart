import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/providers/vocabulary_provider.dart';
import 'package:toeicmobileapp/providers/reading_part5_provider.dart';
import 'package:toeicmobileapp/providers/reading_part6_provider.dart';
import 'package:toeicmobileapp/providers/reading_part7_provider.dart';
import 'package:toeicmobileapp/ui/screens/home/home_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => ReadingPart5Provider()),
        ChangeNotifierProvider(create: (_) => ReadingPart6Provider()),
        ChangeNotifierProvider(create: (_) => ReadingPart7Provider()),
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
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
