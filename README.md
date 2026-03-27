Cấu trúc thư mục (Project Structure - Mobile)
toeic-mobile-app/
├── android/ # Chứa cấu hình google-services.json cho Firebase Android
├── ios/ # Chứa cấu hình GoogleService-Info.plist cho Firebase iOS
├── assets/ # Chứa hình ảnh, âm thanh bài nghe Toeic, fonts
├── lib/
│ ├── core/ # Các thành phần dùng chung hệ thống
│ │ ├── constants/ # App strings, API Endpoints (toeic-backend-api URL)
│ │ ├── theme/ # Cấu hình màu sắc, typography
│ │ └── utils/ # Validator cho Form, helper xử lý Audio
│ ├── data/ # Tầng dữ liệu (Dùng chung cho cả API và Firebase)
│ │ ├── models/ # Model cho User, Question, Lesson, Result
│ │ ├── repositories/ # Logic lấy dữ liệu (từ Firebase hoặc ASP.NET API)
│ │ └── services/ # Firebase Auth, Firebase Messaging, API Client (Dio/Http)
│ ├── providers/ # Quản lý trạng thái (State Management - Provider/Riverpod)
│ │ ├── auth_provider.dart # Xử lý Login/OTP
│ │ ├── exam_provider.dart # Quản lý trạng thái bài thi Toeic
│ │ └── settings_provider.dart # Dark mode, ngôn ngữ
│ ├── ui/ # Tầng giao diện người dùng (End-user)
│ │ ├── screens/ # Các màn hình chính (Layout Structure)
│ │ │ ├── auth/ # Login, Register, Forgot Password screens
│ │ │ ├── home/ # Dashboard, BottomNavigationBar, Drawer
│ │ │ ├── learning/ # List bài học, Chi tiết câu hỏi (ListView/GridView)
│ │ │ └── profile/ # Edit Profile, Change Password
│ │ ├── widgets/ # Các thành phần giao diện nhỏ (Common Widgets)
│ │ │ ├── buttons/ # Custom Buttons, FloatingActionButton
│ │ │ ├── inputs/ # TextField, Checkbox, Radio, Switch
│ │ │ └── cards/ # CardList hiển thị từ vựng/bài thi
│ │ └── shared/ # Dialogs, BottomSheet, Snackbars
│ ├── main.dart # Điểm khởi chạy (Firebase.initializeApp)
│ └── routes.dart # Quản lý điều hướng (Navigator/GoRouter)
└── pubspec.yaml # Khai báo thư viện (firebase_core, dio, provider...)
