import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Hàm lưu trạng thái và điều hướng
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (mounted) {
      // Chuyển hướng thay thế sang AuthWrapper (sẽ định nghĩa ở main.dart)
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient thay đổi động theo trang
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getBackgroundColors(_currentPage),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Lớp phủ hạt ánh sáng mờ tạo cảm giác premium
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://www.transparenttextures.com/patterns/cubes.png',
                    ),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. TOP BRANDING BAR & SKIP BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo mini + Brand Name
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://res.cloudinary.com/dlfc5qwhj/image/upload/q_auto/f_auto/v1780328432/Logo/logo-toeic_2.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'TOEIC Master',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      // Nút Bỏ qua (Skip)
                      if (_currentPage < _numPages - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.85),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            backgroundColor: Colors.white.withOpacity(0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Bỏ qua',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. PAGE VIEW CONTENT
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPage(
                        index: 0,
                        title: 'Từ Vựng & AI Practice',
                        subtitle: 'Học từ vựng TOEIC thông minh qua flashcard và luyện nói/viết trực tiếp với trợ lý AI.',
                        graphic: _buildVocabularyGraphic(),
                      ),
                      _buildPage(
                        index: 1,
                        title: 'Luyện Nghe Smart Listening',
                        subtitle: 'Luyện nghe Part 1-4 trực quan với sóng âm, highlight phụ đề động và tùy chỉnh tốc độ đọc.',
                        graphic: _buildListeningGraphic(),
                      ),
                      _buildPage(
                        index: 2,
                        title: 'Thi Thử & Phân Tích Lộ Trình',
                        subtitle: 'Làm đề thi thử TOEIC chuẩn hóa dưới áp lực thời gian thật và nhận phân tích điểm yếu từ AI.',
                        graphic: _buildExamGraphic(),
                      ),
                    ],
                  ),
                ),

                // 3. BOTTOM CONTROL BAR (DOTS & BUTTONS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicators (Dải dấu chấm động)
                      Row(
                        children: List.generate(
                          _numPages,
                          (index) => _buildPageIndicator(index),
                        ),
                      ),

                      // Nút Tiếp tục / Bắt đầu ngay
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: _currentPage == _numPages - 1 ? 160 : 64,
                        height: 60,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFFFF3E0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                if (_currentPage < _numPages - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                  );
                                } else {
                                  _completeOnboarding();
                                }
                              },
                              child: Center(
                                child: _currentPage == _numPages - 1
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Khám phá',
                                              style: TextStyle(
                                                color: Color(0xFFE06A1A),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Color(0xFFE06A1A),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      )
                                    : const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFFE06A1A),
                                        size: 34,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper trả về danh sách màu Gradient nền
  List<Color> _getBackgroundColors(int page) {
    switch (page) {
      case 0:
        // Tím - Xanh - Cam pha trộn cực hiện đại
        return [
          const Color(0xFF311B92),
          const Color(0xFF1A237E),
          const Color(0xFFE06A1A).withOpacity(0.85),
        ];
      case 1:
        // Aqua sang Emerald mát lạnh
        return [
          const Color(0xFF004D40),
          const Color(0xFF006064),
          const Color(0xFF00897B),
        ];
      case 2:
        // Cam sáng cháy bỏng, đầy năng lượng TOEIC Master
        return [
          const Color(0xFFBF360C),
          const Color(0xFFD84315),
          const Color(0xFFFF8C42),
        ];
      default:
        return [
          const Color(0xFF1A73E8),
          const Color(0xFF1557B0),
        ];
    }
  }

  // Builder tạo Widget cho từng slide giới thiệu
  Widget _buildPage({
    required int index,
    required String title,
    required String subtitle,
    required Widget graphic,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic container ở giữa
          Expanded(
            flex: 6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: graphic,
              ),
            ),
          ),

          // Phần text giới thiệu ở dưới
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.25,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.88),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thiết kế chỉ báo dấu chấm động
  Widget _buildPageIndicator(int index) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
    );
  }

  // GRAPHIC SLIDE 1: Từ vựng & AI nổi bật
  Widget _buildVocabularyGraphic() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Vòng tròn hào quang phát sáng phía sau
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Quả cầu AI trung tâm
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFB07A),
                Color(0xFFFF8C42),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF8C42).withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
        ),

        // Thẻ từ vựng lơ lửng 1 (Góc trên trái)
        Positioned(
          top: 15,
          left: 5,
          child: _buildFloatingCard(
            text: 'Accomplish',
            subText: 'v. Hoàn thành',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF2ECC71),
          ),
        ),

        // Thẻ từ vựng lơ lửng 2 (Góc dưới phải)
        Positioned(
          bottom: 25,
          right: 5,
          child: _buildFloatingCard(
            text: 'Enthusiastic',
            subText: 'adj. Hăng hái',
            icon: Icons.local_fire_department_rounded,
            color: Colors.deepOrange,
          ),
        ),

        // Thẻ từ vựng lơ lửng 3 (Góc dưới trái)
        Positioned(
          bottom: 45,
          left: 10,
          child: _buildFloatingCard(
            text: 'AI Speaking',
            subText: 'Phát âm chuẩn',
            icon: Icons.keyboard_voice_rounded,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  // GRAPHIC SLIDE 2: Trình luyện nghe sóng âm
  Widget _buildListeningGraphic() {
    return Container(
      width: 260,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tiêu đề phụ đề mô phỏng
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Part 1',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sóng âm giả lập chuyển động nhấp nhô
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildWaveBar(20, Colors.white60),
              _buildWaveBar(38, Colors.white70),
              _buildWaveBar(52, Colors.tealAccent),
              _buildWaveBar(28, Colors.white60),
              _buildWaveBar(44, Colors.tealAccent),
              _buildWaveBar(68, Colors.white),
              _buildWaveBar(48, Colors.tealAccent),
              _buildWaveBar(34, Colors.white60),
              _buildWaveBar(58, Colors.tealAccent),
              _buildWaveBar(24, Colors.white.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 18),

          // Bảng chỉnh tốc độ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedBadge('x0.8', false),
              _buildSpeedBadge('x1.0', true), // Tốc độ chuẩn đang chọn
              _buildSpeedBadge('x1.2', false),
              _buildSpeedBadge('x1.5', false),
            ],
          ),
        ],
      ),
    );
  }

  // GRAPHIC SLIDE 3: Bảng thi thử & chỉ số mục tiêu
  Widget _buildExamGraphic() {
    return Container(
      width: 250,
      height: 230,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hộp đếm ngược thời gian giả lập
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: Colors.orangeAccent,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  '01:59:45',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Chỉ số Mục tiêu tròn
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: 0.90, // 90% hoàn thành
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                ),
              ),
              const Column(
                children: [
                  Text(
                    '900+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Target',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Builder tạo thẻ nổi
  Widget _buildFloatingCard({
    required String text,
    required String subText,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                subText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Builder tạo vạch sóng âm
  Widget _buildWaveBar(double height, Color color) {
    return Container(
      width: 6,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // Builder tạo nhãn tốc độ
  Widget _buildSpeedBadge(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.tealAccent : Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.black87 : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
