import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/providers/vocabulary_provider.dart';
import 'package:toeicmobileapp/providers/reading_part5_provider.dart';
import 'package:toeicmobileapp/providers/reading_part6_provider.dart';
import 'package:toeicmobileapp/providers/reading_part7_provider.dart';
import 'package:toeicmobileapp/providers/exam_provider.dart';
import 'package:toeicmobileapp/providers/grammar_provider.dart';
import 'package:toeicmobileapp/providers/listening_provider.dart';
import 'package:toeicmobileapp/providers/speaking_provider.dart';
import 'package:toeicmobileapp/providers/user_provider.dart';
import 'package:toeicmobileapp/providers/writing_provider.dart';
import 'package:toeicmobileapp/core/services/study_reminder_service.dart';
import 'package:toeicmobileapp/ui/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await StudyReminderService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => ReadingPart5Provider()),
        ChangeNotifierProvider(create: (_) => ReadingPart6Provider()),
        ChangeNotifierProvider(create: (_) => ReadingPart7Provider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => GrammarProvider()),
        ChangeNotifierProvider(create: (_) => ListeningProvider()),
        ChangeNotifierProvider(create: (_) => SpeakingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WritingProvider()),
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
      title: 'TOEIC Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Lắng nghe trạng thái đăng nhập để chuyển trang tự động
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Nếu đang chờ Firebase kiểm tra trạng thái
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Nếu đã có thông tin User -> vào Trang chủ
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          // Nếu chưa đăng nhập -> vào trang Login
          return const LoginView();
        },
      ),
    );
  }
}
