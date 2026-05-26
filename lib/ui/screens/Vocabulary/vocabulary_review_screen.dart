import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../../data/repositories/vocabulary_repository.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/vocabulary_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/flashcard/flip_flashcard.dart';
import '../../shared/practice_dialogs.dart';

class VocabularyReviewScreen extends StatefulWidget {
  const VocabularyReviewScreen({super.key});

  @override
  State<VocabularyReviewScreen> createState() => _VocabularyReviewScreenState();
}

class _VocabularyReviewScreenState extends State<VocabularyReviewScreen> {
  final VocabularyRepository _repository = VocabularyRepository();

  List<VocabularyModel> _dueWords = [];
  bool _isLoading = true;
  String? _error;

  int _currentIndex = 0;
  int _earnedEP = 0;
  int _reviewedCount = 0;
  int _easyCount = 0;
  int _hardCount = 0;

  // Floating EP animations
  List<Widget> _floatingTexts = [];

  // Track starred state per word (local optimistic)
  final Map<String, bool> _starredState = {};

  @override
  void initState() {
    super.initState();
    _loadDueWords();
  }

  Future<void> _loadDueWords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _dueWords = await _repository.getDueVocabularies();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _rateWord(int quality) async {
    if (_currentIndex >= _dueWords.length) return;

    final word = _dueWords[_currentIndex];
    _reviewedCount++;
    if (quality >= 4) {
      _easyCount++;
    } else if (quality <= 2) {
      _hardCount++;
    }

    // Gọi API cập nhật progress
    _repository.updateProgress(word.id, quality).then((result) {
      final engagement = result.engagement;
      if (engagement != null) {
        // Cập nhật EP + Streak lên UserProvider toàn cục
        if (mounted) {
          context.read<UserProvider>().updateLocalEpAndStreak(engagement);
        }

        if (engagement.epAwarded > 0) {
          setState(() {
            _earnedEP += engagement.epAwarded;
          });
          _showFloatingEP('+${engagement.epAwarded} EP', Colors.orange, icon: Icons.local_fire_department_rounded);
        } else if (engagement.dailyCapReached) {
          _showSnackbar('Đạt giới hạn 500 EP/ngày 🎯', AppColors.warning);
        }
      }
    }).catchError((e) {
      debugPrint('Error updating progress: $e');
    });

    setState(() {
      _currentIndex++;
    });
  }

  void _toggleStar(VocabularyModel word) {
    final current = _starredState[word.id] ?? word.isStarred;
    setState(() {
      _starredState[word.id] = !current;
    });

    _repository.toggleStar(word.id).then((_) {
      // Cập nhật hub stats nếu cần
      if (mounted) {
        context.read<VocabularyProvider>().fetchHubStats();
      }
    }).catchError((e) {
      // Rollback nếu lỗi
      setState(() {
        _starredState[word.id] = current;
      });
      debugPrint('Toggle star error: $e');
    });
  }

  void _showFloatingEP(String text, Color color, {IconData? icon}) {
    final id = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _floatingTexts.add(
        _FloatingEpAnimation(
          key: ValueKey(id),
          text: text,
          icon: icon,
          color: color,
          onComplete: () {
            if (mounted) {
              setState(() {
                _floatingTexts.removeWhere((w) => w.key == ValueKey(id));
              });
            }
          },
        ),
      );
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex >= _dueWords.length || _dueWords.isEmpty,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final exit = await showExitPracticeDialog(
          context,
          text: 'Tiến trình ôn tập từ vựng của bạn chưa hoàn thành. Bạn có chắc muốn thoát?',
        );
        if (exit && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Ôn tập từ vựng',
          centerTitle: true,
          onBack: () => Navigator.maybePop(context),
        ),
        body: Stack(
          children: [
            _buildBody(),
            ..._floatingTexts,
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Boxicons.bx_wifi_off, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDueWords,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_dueWords.isEmpty) {
      return _buildEmptyState();
    }

    if (_currentIndex >= _dueWords.length) {
      return _buildCompletedState();
    }

    return _buildReviewContent();
  }

  Widget _buildReviewContent() {
    final word = _dueWords[_currentIndex];
    final isStarred = _starredState[word.id] ?? word.isStarred;

    return Column(
      children: [
        // ── Header: Tiến độ + EP + Star ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Text(
                'Tiến độ: ${_currentIndex + 1}/${_dueWords.length}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // EP badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_earnedEP EP',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Nút ⭐ lưu vào sổ tay
              GestureDetector(
                onTap: () => _toggleStar(word),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isStarred
                        ? Colors.amber.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isStarred ? Boxicons.bxs_star : Boxicons.bx_star,
                    color: isStarred ? Colors.amber : AppColors.textHint,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Progress bar ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _dueWords.length,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── FlipFlashcard ────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FlipFlashcard(
              key: ValueKey('${word.id}_$_currentIndex'),
              vocabulary: word,
            ),
          ),
        ),

        const SizedBox(height: 4),
        const Text(
          'Chạm để lật thẻ, sau đó đánh giá mức độ nhớ',
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        const SizedBox(height: 12),

        // ── 4 nút đánh giá SM-2 ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Row(
            children: [
              Expanded(child: _buildRateBtn('Quên', Boxicons.bx_x, AppColors.error, 1)),
              const SizedBox(width: 8),
              Expanded(child: _buildRateBtn('Khó', Boxicons.bx_confused, AppColors.warning, 2)),
              const SizedBox(width: 8),
              Expanded(child: _buildRateBtn('Ổn', Boxicons.bx_smile, AppColors.info, 3)),
              const SizedBox(width: 8),
              Expanded(child: _buildRateBtn('Dễ', Boxicons.bx_happy, AppColors.green, 5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRateBtn(String label, IconData icon, Color color, int quality) {
    return ElevatedButton(
      onPressed: () => _rateWord(quality),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.12),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withOpacity(0.35)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: AppColors.greenBg, shape: BoxShape.circle),
            child: const Icon(Boxicons.bx_check_circle, size: 56, color: AppColors.green),
          ),
          const SizedBox(height: 20),
          const Text('Tuyệt vời! 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Không có từ nào cần ôn tập.\nHãy quay lại sau nhé!',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Boxicons.bx_arrow_back, size: 18),
            label: const Text('Quay lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Boxicons.bx_trophy, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('Hoàn thành ôn tập! 🏆',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Bạn đã ôn $_reviewedCount từ và nhận được $_earnedEP EP',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBadge('Đã ôn', _reviewedCount, AppColors.primary),
                  _buildStatBadge('Dễ', _easyCount, AppColors.green),
                  _buildStatBadge('Khó', _hardCount, AppColors.error),
                  _buildStatBadge('EP', _earnedEP, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Boxicons.bx_home, size: 20),
                label: const Text('Về trang chủ', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Animation EP bay lên ─────────────────────────────────────────────────────
class _FloatingEpAnimation extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final VoidCallback onComplete;

  const _FloatingEpAnimation({
    super.key,
    required this.text,
    this.icon,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_FloatingEpAnimation> createState() => _FloatingEpAnimationState();
}

class _FloatingEpAnimationState extends State<_FloatingEpAnimation>
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
    _position = Tween<double>(begin: 0.0, end: 140.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topOffset = mediaQuery.size.height * 0.38;
    final rightOffset = mediaQuery.size.width * 0.08;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: topOffset - _position.value,
          right: rightOffset,
          child: Opacity(
            opacity: _opacity.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: widget.color,
                    shadows: const [
                      Shadow(blurRadius: 10, color: Colors.white, offset: Offset(0, 0)),
                      Shadow(blurRadius: 5, color: Colors.black26, offset: Offset(2, 2)),
                    ],
                  ),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    widget.icon,
                    color: widget.color,
                    size: 34,
                    shadows: const [
                      Shadow(blurRadius: 10, color: Colors.white, offset: Offset(0, 0)),
                      Shadow(blurRadius: 5, color: Colors.black26, offset: Offset(2, 2)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
