import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../core/services/tts_service.dart';
import '../../widgets/vocabulary/matching_card.dart';
import '../../widgets/common/practice_result_view.dart';
import '../../../providers/user_provider.dart';
import '../../shared/practice_dialogs.dart';

class VocabularyMatchingScreen extends StatefulWidget {
  final List<VocabularyModel> words;

  const VocabularyMatchingScreen({super.key, required this.words});

  @override
  State<VocabularyMatchingScreen> createState() => _VocabularyMatchingScreenState();
}

class _VocabularyMatchingScreenState extends State<VocabularyMatchingScreen> with TickerProviderStateMixin {
  // Dữ liệu lượt chơi hiện tại
  late List<VocabularyModel> _allWords;
  List<VocabularyModel> _unmatchedWords = [];
  List<VocabularyModel> _unmatchedDefs = [];
  List<VocabularyModel> _currentBatchMatched = []; 
  
  // Trạng thái đang biến mất (để làm hiệu ứng rơi)
  Set<String> _dyingIds = {};

  // Trạng thái chọn
  String? _selectedWordId;
  String? _selectedDefId;
  
  // Điểm số & Tiến độ
  int _mistakes = 0;
  int _totalMatched = 0;
  int _batchIndex = 0;
  bool _isFinished = false;
  bool _showContinueButton = false;
  int  _epAwarded   = 0;
  bool _epLoading   = false;
  int  _attemptCount = 0;  // 0 = lần đầu, 1+ = luyện lại

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _allWords = List.from(widget.words)..shuffle();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _loadNextBatch();
  }

  void _loadNextBatch() {
    final start = _batchIndex * 5;
    if (start >= _allWords.length) {
      // Hoàn thành tất cả — cộng EP
      _awardEpAndFinish();
      return;
    }

    final end = (start + 5 > _allWords.length) ? _allWords.length : start + 5;
    final batch = _allWords.sublist(start, end);
    
    setState(() {
      _unmatchedWords = List.from(batch)..shuffle();
      _unmatchedDefs = List.from(batch)..shuffle();
      _currentBatchMatched = [];
      _dyingIds = {};
      _selectedWordId = null;
      _selectedDefId = null;
      _showContinueButton = false;
    });
  }

  void _handleWordSelect(String id) {
    if (_showContinueButton || _dyingIds.contains(id)) return;
    setState(() {
      _selectedWordId = id;
      _checkMatch();
    });
  }

  void _handleDefSelect(String id) {
    if (_showContinueButton || _dyingIds.contains(id)) return;
    setState(() {
      _selectedDefId = id;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (_selectedWordId != null && _selectedDefId != null) {
      if (_selectedWordId == _selectedDefId) {
        final matchedId = _selectedWordId!;
        HapticFeedback.lightImpact();
        
        final matchedWord = _allWords.firstWhere((w) => w.id == matchedId);
        TtsService().speak(matchedWord.word);

        setState(() {
          _dyingIds.add(matchedId); // Kích hoạt hiệu ứng rơi mờ
          _selectedWordId = null;
          _selectedDefId = null;
        });

        // Đợi hiệu ứng rơi xong mới xóa khỏi danh sách và hiện lên trên
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _totalMatched++;
              _currentBatchMatched.add(matchedWord);
              _unmatchedWords.removeWhere((w) => w.id == matchedId);
              _unmatchedDefs.removeWhere((w) => w.id == matchedId);
              _dyingIds.remove(matchedId);

              if (_unmatchedWords.isEmpty) {
                _showContinueButton = true;
              }
            });
          }
        });
      } else {
        HapticFeedback.heavyImpact();
        _mistakes++;
        _shakeController.forward(from: 0);
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _selectedWordId = null;
              _selectedDefId = null;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResultScreen();

    return PopScope(
      canPop: _isFinished,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final exit = await showExitPracticeDialog(
          context,
          text: 'Tiến trình Ghép cặp từ vựng của bạn chưa hoàn thành. Bạn có chắc muốn thoát?',
        );
        if (exit && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Ghép cặp',
          centerTitle: true,
          onBack: () => Navigator.maybePop(context),
        ),
        body: Column(
        children: [
          _buildHeader(),
          
          if (_currentBatchMatched.isNotEmpty) _buildMatchedArea(),

          Expanded(
            child: Row(
              children: [
                _buildColumn(_unmatchedWords, true),
                _buildColumn(_unmatchedDefs, false),
              ],
            ),
          ),
          
          if (_showContinueButton) _buildContinueButton(),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _totalMatched / _allWords.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã ghép: $_totalMatched/${_allWords.length}', 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Lỗi: $_mistakes', 
                   style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
            minHeight: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _currentBatchMatched.map((w) => _buildMatchedChip(w)).toList(),
      ),
    );
  }

  Widget _buildMatchedChip(VocabularyModel word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Boxicons.bx_check_circle, color: AppColors.success, size: 14),
          const SizedBox(width: 6),
          Text(
            '${word.word} (${word.wordType}): ${word.definitionVi}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(List<VocabularyModel> items, bool isWord) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = isWord ? (_selectedWordId == item.id) : (_selectedDefId == item.id);
          final isDying = _dyingIds.contains(item.id);

          return MatchingCard(
            text: isWord ? '${item.word}\n(${item.wordType})' : item.definitionVi,
            isSelected: isSelected,
            isDying: isDying,
            isError: isSelected && (isWord ? _selectedDefId : _selectedWordId) != null && 
                     (isWord ? _selectedWordId : _selectedDefId) != (isWord ? _selectedDefId : _selectedWordId), 
            shakeAnimation: isSelected ? _shakeController : null,
            onTap: () => isWord ? _handleWordSelect(item.id) : _handleDefSelect(item.id),
          );
        },
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            _batchIndex++;
            _loadNextBatch();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('TIẾP TỤC', style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Boxicons.bx_right_arrow_alt, color: AppColors.textOnPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _awardEpAndFinish() async {
    setState(() {
      _isFinished = true;
      _epLoading  = true;
    });
    final effectiveCorrect = _attemptCount == 0 ? _totalMatched : (_totalMatched ~/ 2);
    final result = await context.read<UserProvider>().recordActivity(
      activityType  : 'VocabMatching',
      correctAnswers: effectiveCorrect,
      totalAnswers  : _allWords.length,
    );
    if (mounted) {
      setState(() {
        _epAwarded = result?.epAwarded ?? 0;
        _epLoading = false;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _allWords.shuffle();
      _batchIndex   = 0;
      _mistakes     = 0;
      _totalMatched = 0;
      _isFinished   = false;
      _showContinueButton = false;
      _epAwarded    = 0;
      _epLoading    = false;
      _attemptCount++;
    });
    _loadNextBatch();
  }

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PracticeResultView(
        score    : _totalMatched,
        total    : _allWords.length,
        mistakes : _mistakes,
        epAwarded: _epAwarded,
        epLoading: _epLoading,
        isRetry  : _attemptCount > 0,
        onRetry  : _resetGame,
        onBack   : () => Navigator.pop(context),
      ),
    );
  }
}
