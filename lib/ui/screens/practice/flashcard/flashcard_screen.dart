import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../../data/models/vocabulary_model.dart';
import '../../../../data/repositories/vocabulary_repository.dart';
import '../../../../providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/flashcard/flip_flashcard.dart';
import '../../../widgets/common/custom_app_bar.dart';

class FlashcardScreen extends StatefulWidget {
  final List<VocabularyModel> vocabularies;

  const FlashcardScreen({super.key, required this.vocabularies});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final CardSwiperController controller = CardSwiperController();
  final VocabularyRepository _repository = VocabularyRepository();
  late List<VocabularyModel> remainingCards;
  int earnedEP = 0;
  int _currentIndex = 0;
  late int _totalInitialCount;

  // Danh sách các Widget animation bay lên
  List<Widget> _floatingTexts = [];

  @override
  void initState() {
    super.initState();
    remainingCards = List.from(widget.vocabularies);
    _totalInitialCount = remainingCards.length;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final vocabId = remainingCards[previousIndex].id;

    if (direction == CardSwiperDirection.right) {
      // Đã thuộc (Swipe right) - chất lượng SRS = 4
      _repository.updateProgress(vocabId, 4).then((result) {
        final days = result.progress.interval.round();
        final message = days <= 0
            ? "Ôn lại ngay!"
            : "Hẹn gặp lại sau $days ngày";
        
        _showSnackbar("Đã thuộc! $message", AppColors.success);

        final engagement = result.engagement;
        if (engagement != null) {
          // Cộng EP và cập nhật Streak lên Provider toàn cục
          context.read<UserProvider>().updateLocalEpAndStreak(engagement);

          if (engagement.epAwarded > 0) {
            Future.microtask(() {
              setState(() {
                earnedEP += engagement.epAwarded;
                _currentIndex++;
              });
            });
            _showFloatingEP("+${engagement.epAwarded} EP 🔥", Colors.orange);
          } else if (engagement.dailyCapReached) {
            Future.microtask(() {
              setState(() {
                _currentIndex++;
              });
            });
            _showSnackbar("Đã thuộc! (Đạt giới hạn 500 EP/ngày)", AppColors.warning);
          } else {
            Future.microtask(() {
              setState(() {
                _currentIndex++;
              });
            });
          }
        } else {
          Future.microtask(() {
            setState(() {
              earnedEP += 5; // Dự phòng
              _currentIndex++;
            });
          });
          _showFloatingEP("+5 EP 🌟", Colors.orange);
        }
      }).catchError((e) {
        debugPrint("Lỗi cập nhật tiến trình từ vựng: $e");
        Future.microtask(() {
          setState(() {
            earnedEP += 5; // Dự phòng khi ngoại lệ
            _currentIndex++;
          });
        });
        _showFloatingEP("+5 EP", Colors.orange);
      });

    } else if (direction == CardSwiperDirection.left) {
      // 未 thuộc (Swipe left) - chất lượng SRS = 0
      Future.microtask(() {
        setState(() {
          remainingCards.add(remainingCards[previousIndex]);
        });
      });
      _repository.updateProgress(vocabId, 0).catchError((e) {
        debugPrint("Lỗi cập nhật chưa thuộc: $e");
      });
      _showSnackbar("Chưa thuộc! Từ này sẽ xuất hiện lại ở cuối xấp để bạn ôn tập.", AppColors.error);
    }
    return true;
  }

  void _showFloatingEP(String text, Color color) {
    // Tạo một ID ngẫu nhiên cho animation
    final id = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _floatingTexts.add(
        _FloatingTextAnimation(
          key: ValueKey(id),
          text: text,
          color: color,
          onComplete: () {
            setState(() {
              _floatingTexts.removeWhere(
                (widget) => widget.key == ValueKey(id),
              );
            });
          },
        ),
      );
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEnd() {
    // Hoàn thành bộ Flashcard (không tự ý cộng 50 EP ảo nữa)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Chúc Mừng! ", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Bạn đã hoàn thành xấp Flashcard!"),
            const SizedBox(height: 15),
            Text(
              "Tổng EP thực nhận: $earnedEP 🔥",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Tuyệt vời",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "Luyện Flashcard"),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tiến độ: ${_currentIndex > _totalInitialCount ? _totalInitialCount : _currentIndex} / $_totalInitialCount",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        " $earnedEP EP",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: remainingCards.isEmpty
                    ? const Center(child: Text("Không có từ vựng nào!"))
                    : CardSwiper(
                        controller: controller,
                        cardsCount: remainingCards.length,
                        onSwipe: _onSwipe,
                        onEnd: _onEnd,
                        allowedSwipeDirection:
                            const AllowedSwipeDirection.symmetric(
                              horizontal: true,
                            ),
                        padding: const EdgeInsets.all(24.0),
                        cardBuilder:
                            (
                              context,
                              index,
                              percentThresholdX,
                              percentThresholdY,
                            ) {
                              final vocab = remainingCards[index];
                              return FlipFlashcard(
                                key: ValueKey('${vocab.id}_$index'),
                                vocabulary: vocab,
                              );
                            },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Boxicons.bx_x,
                      color: AppColors.error,
                      onTap: () => controller.swipe(CardSwiperDirection.left),
                      label: "Chưa thuộc",
                    ),
                    _buildActionButton(
                      icon: Boxicons.bx_check,
                      color: AppColors.success,
                      onTap: () => controller.swipe(CardSwiperDirection.right),
                      label: "Đã thuộc",
                    ),
                  ],
                ),
              ),
            ],
          ), // Đóng Column
          // Lớp Overlay để hiển thị Animation bay lên
          ..._floatingTexts,
        ],
      ), // Đóng Stack
    ); // Đóng Scaffold
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Widget xử lý animation bay chữ lên
class _FloatingTextAnimation extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onComplete;

  const _FloatingTextAnimation({
    super.key,
    required this.text,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_FloatingTextAnimation> createState() => _FloatingTextAnimationState();
}

class _FloatingTextAnimationState extends State<_FloatingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _position = Tween<double>(
      begin: 0.0,
      end: 150.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.4 - _position.value,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Opacity(
            opacity: _opacity.value,
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: widget.color,
                shadows: const [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  ),
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
