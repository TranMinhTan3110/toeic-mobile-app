import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../../providers/vocabulary_provider.dart';
import '../../widgets/vocabulary/lesson_selector_row.dart';
import '../../widgets/vocabulary/action_button_row.dart';
import '../../widgets/vocabulary/vocabulary_card.dart';
import '../../../core/services/tts_service.dart';
import 'vocabulary_quiz_screen.dart';
import 'vocabulary_matching_screen.dart';
import 'vocabulary_ai_writing_screen.dart';
import 'vocabulary_speaking_screen.dart';
import 'quiz_helper.dart';

import '../../widgets/common/custom_app_bar.dart';
import '../practice/flashcard/flashcard_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String? _selectedLesson; 
  String? _selectedLevel;
  bool _isInit = true;
  bool _isSelectMode = false;
  final Set<String> _selectedWordIds = {};

  void _showNoSelectionWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng chọn ít nhất 1 từ vựng để luyện tập!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  List<VocabularyModel> _getTargetWords(List<VocabularyModel> allWords) {
    if (_isSelectMode && _selectedWordIds.isNotEmpty) {
      return allWords.where((w) => _selectedWordIds.contains(w.id)).toList();
    }
    return allWords;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<VocabularyProvider>();
    await provider.fetchMetadata();
    
    if (provider.topics.isNotEmpty && provider.levels.isNotEmpty) {
      setState(() {
        _selectedLesson = provider.topics.first;
        _selectedLevel = provider.levels.first;
        _isInit = false;
      });
      _onLessonOrLevelChanged();
    }
  }

  void _onLessonOrLevelChanged() {
    if (_selectedLesson != null && _selectedLevel != null) {
      context.read<VocabularyProvider>().fetchVocabularies(
        _selectedLesson!,
        _selectedLevel!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Lý thuyết - Từ vựng',
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner giả lập
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Boxicons.bx_smile, color: Colors.orange, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Từ điển Anh Việt Dunno',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tra cứu giọng nói, hình ảnh OCR',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text(
                    'Tải ngay',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Lọc Bài và Cấp độ
          Consumer<VocabularyProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && _isInit) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(color: AppColors.primary),
                );
              }
              
              if (provider.errorMessage != null && _isInit) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              return LessonSelectorRow(
                selectedLesson: _selectedLesson ?? '',
                selectedLevel: _selectedLevel ?? '',
                lessons: provider.topics,
                levels: provider.levels,
                onLessonChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedLesson = v);
                    _onLessonOrLevelChanged();
                  }
                },
                onLevelChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedLevel = v);
                    _onLessonOrLevelChanged();
                  }
                },
              );
            },
          ),

          // Các nút chức năng
          Consumer<VocabularyProvider>(
            builder: (context, provider, child) {
              return ActionButtonRow(
                isSelectMode: _isSelectMode,
                onToggleSelect: () {
                  setState(() {
                    _isSelectMode = !_isSelectMode;
                    if (!_isSelectMode) {
                      _selectedWordIds.clear();
                    }
                  });
                },
                onFlashcards: () {
                  if (_isSelectMode && _selectedWordIds.isEmpty) {
                    _showNoSelectionWarning();
                    return;
                  }
                  final target = _getTargetWords(provider.words);
                  if (target.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardScreen(
                          vocabularies: target,
                        ),
                      ),
                    );
                  }
                },
                onChooseWord: () {
                  if (_isSelectMode && _selectedWordIds.isEmpty) {
                    _showNoSelectionWarning();
                    return;
                  }
                  final target = _getTargetWords(provider.words);
                  if (target.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyQuizScreen(
                          words: target,
                          quizType: QuizType.wordToDefinition,
                        ),
                      ),
                    );
                  }
                },
                onDefinition: () {
                  if (_isSelectMode && _selectedWordIds.isEmpty) {
                    _showNoSelectionWarning();
                    return;
                  }
                  final target = _getTargetWords(provider.words);
                  if (target.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyMatchingScreen(
                          words: target,
                        ),
                      ),
                    );
                  }
                },
                onMakeSentence: () {
                  if (_isSelectMode && _selectedWordIds.isEmpty) {
                    _showNoSelectionWarning();
                    return;
                  }
                  final target = _getTargetWords(provider.words);
                  if (target.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyAiWritingScreen(
                          words: target,
                          initialIndex: 0,
                        ),
                      ),
                    );
                  }
                }, 
                onSpeaking: () {
                  if (_isSelectMode && _selectedWordIds.isEmpty) {
                    _showNoSelectionWarning();
                    return;
                  }
                  final target = _getTargetWords(provider.words);
                  if (target.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularySpeakingScreen(
                          words: target,
                          initialIndex: 0,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),

          const SizedBox(height: 8),

          // Danh sách từ vựng theo trạng thái
          Expanded(
            child: Consumer<VocabularyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final words = provider.words;
                if (words.isEmpty) {
                  return const Center(
                    child: Text('Không có từ vựng nào thuộc chủ đề này.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final item = words[index];
                    return VocabularyCard(
                      word: item,
                      isSelectMode: _isSelectMode,
                      isSelected: _selectedWordIds.contains(item.id),
                      onSelect: () {
                        setState(() {
                          if (_selectedWordIds.contains(item.id)) {
                            _selectedWordIds.remove(item.id);
                          } else {
                            _selectedWordIds.add(item.id);
                          }
                        });
                      },
                      onAudio: () {
                        // Phát âm từ ngay tại danh sách
                        TtsService().speak(item.word);
                      },
                      onStar: () {
                        provider.toggleStar(item.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
