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
import 'package:toeicmobileapp/ui/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/intro/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Đọc cờ showOnboarding từ bộ nhớ cục bộ
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => GrammarProvider()),
        
        ChangeNotifierProxyProvider<UserProvider, ReadingPart5Provider>(
          create: (_) => ReadingPart5Provider(),
          update: (_, userProvider, readingProvider) =>
              readingProvider!..setUserProvider(userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, ReadingPart6Provider>(
          create: (_) => ReadingPart6Provider(),
          update: (_, userProvider, readingProvider) =>
              readingProvider!..setUserProvider(userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, ReadingPart7Provider>(
          create: (_) => ReadingPart7Provider(),
          update: (_, userProvider, readingProvider) =>
              readingProvider!..setUserProvider(userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, ListeningProvider>(
          create: (_) => ListeningProvider(),
          update: (_, userProvider, listeningProvider) =>
              listeningProvider!..setUserProvider(userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, SpeakingProvider>(
          create: (_) => SpeakingProvider(),
          update: (_, userProvider, speakingProvider) =>
              speakingProvider!..setUserProvider(userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, WritingProvider>(
          create: (_) => WritingProvider(),
          update: (_, userProvider, writingProvider) =>
              writingProvider!..setUserProvider(userProvider),
        ),
      ],
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

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
      // Đăng ký các route tĩnh để điều hướng thay thế dễ dàng
      routes: {
        '/auth': (context) => const AuthWrapper(),
      },
      // Trang chủ động: Lần đầu mở thì hiện giới thiệu, các lần sau vào thẳng luồng auth
      home: showOnboarding ? const OnboardingScreen() : const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
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
    );
  }
}
