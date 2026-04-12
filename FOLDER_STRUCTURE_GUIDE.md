# 📁 Hướng Dẫn Cấu Trúc Thư Mục – TOEIC Mobile App

> Dự án sử dụng **Flutter** với kiến trúc phân tầng rõ ràng: `core` → `data` → `providers` → `ui`.  
> Mục tiêu: dễ bảo trì, dễ mở rộng, tách biệt logic và giao diện.

---

File hướng dẫn và code mẫu sẵn cũng chỉ là tham khảo, quan trọng là hiểu được logic và cách áp dụng vào dự án thực tế.

## 🗂️ Tổng Quan Cấu Trúc

```
toeic-mobile-app/
├── lib/
│   ├── main.dart               ← Entry point của app
│   ├── core/                   ← Cấu hình, hằng số, tiện ích dùng chung
│   │   ├── constants/          ← Màu sắc, chuỗi văn bản, kích thước cố định
│   │   ├── theme/              ← Theme toàn cục (ThemeData)
│   │   └── utils/              ← Hàm tiện ích (format ngày, validator, v.v.)
│   ├── data/                   ← Tầng dữ liệu (Model, API, Repository)
│   │   ├── models/             ← Các class dữ liệu (User, Question, Lesson...)
│   │   ├── services/           ← Gọi API / Firebase trực tiếp
│   │   └── repositories/       ← Trung gian giữa services và providers
│   ├── providers/              ← Quản lý state (Riverpod / Provider / BLoC)
│   └── ui/                     ← Tầng giao diện
│       ├── screens/            ← Các màn hình (trang đầy đủ)
│       ├── widgets/            ← Widget tái sử dụng (button, card, v.v.)
│       └── shared/             ← Layout, navbar, drawer chung
├── pubspec.yaml                ← Khai báo dependencies
└── assets/                     ← Hình ảnh, font (tạo thêm khi cần)
```

---

## 📄 `lib/main.dart`

**Vai trò:** Khởi động toàn bộ ứng dụng.

```dart
void main() {
  runApp(const MyApp());
}
```

**Code ở đây:**
- Khởi tạo Firebase (`Firebase.initializeApp()`)
- Bọc app trong `ProviderScope` (nếu dùng Riverpod) hoặc `MultiProvider`
- Khai báo `MaterialApp` với `theme`, `routes`, `initialRoute`

**Không nên code ở đây:**
- Logic nghiệp vụ
- Gọi API
- Widget UI phức tạp

---

## 🔧 `lib/core/`

Chứa những thứ **không thay đổi theo tính năng** – dùng ở mọi nơi trong app.

### 📂 `core/constants/`

**Vai trò:** Lưu các giá trị cố định, tránh magic string/number.

```dart
// lib/core/constants/app_colors_home.dart
class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color accent  = Color(0xFF42A5F5);
  static const Color error   = Color(0xFFD32F2F);
  static const Color background = Color(0xFFF5F5F5);
}

// lib/core/constants/app_strings.dart
class AppStrings {
  static const String appName   = 'TOEIC Master';
  static const String loginTitle = 'Đăng nhập';
  static const String startLesson = 'Bắt đầu học';
}

// lib/core/constants/app_sizes.dart
class AppSizes {
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double borderRadius = 12.0;
}
```

**Khi nào dùng:** Bất cứ khi nào bạn định gõ thẳng `Color(0xFF...)`, `'Đăng nhập'`, hay `16.0` – hãy khai báo ở đây.

---

### 📂 `core/theme/`

**Vai trò:** Định nghĩa giao diện toàn cục một lần, áp dụng xuyên suốt app.

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
    ),
  );
}

// Dùng trong main.dart:
MaterialApp(theme: AppTheme.lightTheme, ...)
```

---

### 📂 `core/utils/`

**Vai trò:** Hàm helper không gắn với business logic cụ thể.

```dart
// lib/core/utils/date_formatter.dart
class DateFormatter {
  static String format(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

// lib/core/utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || !value.contains('@')) return 'Email không hợp lệ';
    return null;
  }
}

// lib/core/utils/snackbar_helper.dart
void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
```

---

## 💾 `lib/data/`

Tầng dữ liệu – **không được import bất kỳ widget UI nào** ở đây.

### 📂 `data/models/`

**Vai trò:** Định nghĩa cấu trúc dữ liệu, parse JSON từ API/Firebase.

```dart
// lib/data/models/question_model.dart
class QuestionModel {
  final String id;
  final String content;
  final List<String> options;
  final String correctAnswer;
  final String? audioUrl;

  QuestionModel({
    required this.id,
    required this.content,
    required this.options,
    required this.correctAnswer,
    this.audioUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      content: json['content'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      audioUrl: json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'options': options,
    'correct_answer': correctAnswer,
    'audio_url': audioUrl,
  };
}
```

**Quy tắc đặt tên file:** `[tên_entity]_model.dart`  
Ví dụ: `user_model.dart`, `lesson_model.dart`, `test_result_model.dart`

---

### 📂 `data/services/`

**Vai trò:** Giao tiếp trực tiếp với nguồn dữ liệu bên ngoài (Firebase, REST API).

```dart
// lib/data/services/question_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionService {
  final String _baseUrl = 'https://your-api.com/api';

  Future<List<QuestionModel>> getQuestions(String lessonId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lessons/$lessonId/questions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => QuestionModel.fromJson(e)).toList();
    }
    throw Exception('Không thể tải câu hỏi');
  }
}

// lib/data/services/auth_service.dart – dành cho Firebase Auth
class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();
}
```

**Quy tắc:** Mỗi service chỉ xử lý một domain.  
Ví dụ: `auth_service.dart`, `lesson_service.dart`, `result_service.dart`

---

### 📂 `data/repositories/`

**Vai trò:** Lớp trung gian – che giấu nguồn dữ liệu, là nơi duy nhất Providers gọi đến.

```dart
// lib/data/repositories/question_repository.dart
class QuestionRepository {
  final QuestionService _service;
  QuestionRepository(this._service);

  Future<List<QuestionModel>> fetchQuestions(String lessonId) async {
    // Có thể thêm cache logic ở đây sau
    return _service.getQuestions(lessonId);
  }
}
```

> **Tại sao cần Repository?**  
> Nếu sau này bạn đổi từ REST API sang GraphQL hay thay đổi cách cache, bạn chỉ cần sửa ở repository, không cần đụng providers hay UI.

---

## ⚙️ `lib/providers/`

**Vai trò:** Quản lý state của app – cầu nối giữa `data` và `ui`.

```dart
// lib/providers/question_provider.dart  (dùng Riverpod làm ví dụ)
final questionProvider = FutureProvider.family<List<QuestionModel>, String>(
  (ref, lessonId) async {
    final repo = ref.read(questionRepositoryProvider);
    return repo.fetchQuestions(lessonId);
  },
);

// lib/providers/auth_provider.dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(AuthState.initial());
  final AuthRepository _repo;

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _repo.login(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
```

**Quy tắc đặt tên file:** `[tên_feature]_provider.dart`  
Ví dụ: `auth_provider.dart`, `lesson_provider.dart`, `score_provider.dart`

---

## 🎨 `lib/ui/`

Tầng giao diện – chỉ được import từ `providers` và `core`. **Không import trực tiếp `services`.**

### 📂 `ui/screens/`

**Vai trò:** Mỗi file là một **màn hình đầy đủ** (fullscreen page), được điều hướng tới bằng `Navigator` hoặc `GoRouter`.

```dart
// lib/ui/screens/home/home_screen.dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang Chủ')),
      body: Column(
        children: [
          // Dùng widget đã tách từ ui/widgets/
          const WelcomeBanner(),
          LessonListSection(),
        ],
      ),
    );
  }
}
```

**Quy tắc tổ chức screens:**
```
screens/
├── auth/
│   ├── login_screen.dart
│   └── register_screen.dart
├── home/
│   └── home_screen.dart
├── lesson/
│   ├── lesson_list_screen.dart
│   └── lesson_detail_screen.dart
├── practice/
│   ├── practice_screen.dart
│   └── result_screen.dart
└── profile/
    └── profile_screen.dart
```

**Màn hình KHÔNG nên:**
- Chứa logic gọi API trực tiếp (để provider làm)
- Chứa widget phức tạp inline (tách ra `widgets/`)

---

### 📂 `ui/widgets/`

**Vai trò:** Widget **tái sử dụng** – được gọi từ nhiều màn hình khác nhau.  
Đây là kho "linh kiện" của app.

```dart
// lib/ui/widgets/lesson_card.dart
class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final int totalQuestions;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.totalQuestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              Text(description),
              Text('$totalQuestions câu hỏi'),
            ],
          ),
        ),
      ),
    );
  }
}

// Dùng ở bất kỳ màn hình nào:
LessonCard(
  title: 'Part 1 – Photographs',
  description: 'Nghe và chọn mô tả đúng cho ảnh',
  totalQuestions: 6,
  onTap: () => Navigator.push(...),
)
```

**Ví dụ các widget nên tạo:**

| File | Mô tả |
|------|-------|
| `lesson_card.dart` | Card bài học |
| `question_card.dart` | Card câu hỏi TOEIC |
| `option_button.dart` | Nút chọn đáp án (A/B/C/D) |
| `score_badge.dart` | Huy hiệu điểm số |
| `audio_player_widget.dart` | Trình phát audio inline |
| `progress_bar_widget.dart` | Thanh tiến trình bài học |
| `loading_overlay.dart` | Overlay loading toàn màn hình |
| `empty_state_widget.dart` | Khi danh sách rỗng |
| `error_widget.dart` | Hiển thị lỗi có nút retry |
| `custom_button.dart` | Nút bấm custom có style thống nhất |

**Quy tắc:** Widget phải **độc lập** – nhận data qua constructor, không tự gọi provider bên trong (trừ khi thực sự cần show/hide state).

---

### 📂 `ui/shared/`

**Vai trò:** Các thành phần layout **xuất hiện xuyên suốt nhiều màn hình** (không phải widget độc lập).

```dart
// lib/ui/shared/app_bottom_nav.dart
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bài học'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Kết quả'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}

// lib/ui/shared/app_drawer.dart   ← Sidebar menu
// lib/ui/shared/main_layout.dart  ← Scaffold bọc chung
```

---

## 📦 `assets/` *(Cần tạo thêm)*

```
assets/
├── images/         ← Logo, banner, ảnh nền
├── icons/          ← Icon SVG custom
├── audio/          ← File âm thanh mẫu (nếu offline)
└── fonts/          ← Font tùy chỉnh
```

Khai báo trong `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

---

## 🔄 Luồng Dữ Liệu

```
Firebase / REST API
        ↓
  data/services/       ← Gọi trực tiếp API
        ↓
  data/repositories/   ← Trộn/cache/xử lý data
        ↓
  providers/           ← Quản lý state, expose cho UI
        ↓
  ui/screens/          ← Màn hình, watch provider
        ↓
  ui/widgets/          ← Hiển thị data, nhận callback
```

---

## ✅ Checklist Khi Thêm Tính Năng Mới

Ví dụ thêm tính năng **"Luyện tập Part 5 - Grammar"**:

- [ ] **Model**: Tạo `lib/data/models/grammar_question_model.dart`
- [ ] **Service**: Tạo `lib/data/services/grammar_service.dart` (gọi API)
- [ ] **Repository**: Tạo `lib/data/repositories/grammar_repository.dart`
- [ ] **Provider**: Tạo `lib/providers/grammar_provider.dart`
- [ ] **Widget**: Tạo `lib/ui/widgets/grammar_option_button.dart` (nếu cần riêng)
- [ ] **Screen**: Tạo `lib/ui/screens/practice/grammar_practice_screen.dart`
- [ ] **Route**: Thêm route vào `main.dart` hoặc router file

---

## 🚫 Những Lỗi Thường Gặp

| ❌ Sai | ✅ Đúng |
|--------|---------|
| Gọi `http.get()` thẳng trong widget | Gọi qua `service` rồi `repository` |
| Viết logic trong `Screen` | Đưa vào `Provider` |
| Tạo widget dài 200 dòng inline | Tách thành file riêng trong `widgets/` |
| Dùng màu `Color(0xFF...)` cố định | Dùng `AppColors.primary` |
| Dùng padding `16.0` cứng | Dùng `AppSizes.paddingM` |
| Đặt tên file `Widget1.dart` | Đặt theo chức năng: `lesson_card.dart` |

---

*Tài liệu này nên được cập nhật mỗi khi thêm một tầng hoặc pattern mới vào dự án.*
