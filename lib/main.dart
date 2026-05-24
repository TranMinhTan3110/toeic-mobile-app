import 'package:flutter/material.dart';
import 'ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/providers/vocabulary_provider.dart';
import 'package:toeicmobileapp/providers/user_provider.dart';
import 'package:toeicmobileapp/providers/speaking_provider.dart';
import 'package:toeicmobileapp/providers/listening_provider.dart';
import 'package:toeicmobileapp/ui/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toeicmobileapp/ui/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SpeakingProvider()),
        ChangeNotifierProvider(create: (_) => ListeningProvider()),
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
        fontFamily: 'Poppins',
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
