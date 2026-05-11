import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../../data/services/ai_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class VocabularyAiWritingScreen extends StatefulWidget {
  final List<VocabularyModel> words;
  final int initialIndex;

  const VocabularyAiWritingScreen({
    super.key,
    required this.words,
    this.initialIndex = 0,
  });

  @override
  State<VocabularyAiWritingScreen> createState() => _VocabularyAiWritingScreenState();
}

class _VocabularyAiWritingScreenState extends State<VocabularyAiWritingScreen> {
  final TextEditingController _controller = TextEditingController();
  final AiService _aiService = AiService();
  
  late int _currentIndex;
  bool _isAnalyzing = false;
  bool _isLoadingScenario = false;
  String? _aiResponse;
  String? _scenario;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fetchScenario();
  }

  VocabularyModel get _currentWord => widget.words[_currentIndex];

  void _fetchScenario() async {
    setState(() {
      _isLoadingScenario = true;
      _aiResponse = null;
      _controller.clear();
    });

    try {
      final res = await _aiService.getScenario(_currentWord.word, _currentWord.definitionVi);
      setState(() {
        _scenario = res['result'];
        _isLoadingScenario = false;
      });
    } catch (e) {
      setState(() {
        _scenario = "Hãy đặt một câu với từ '${_currentWord.word}' trong bối cảnh công việc.";
        _isLoadingScenario = false;
      });
    }
  }

  void _handleNextWord() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _fetchScenario();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã hoàn thành tất cả từ vựng trong chủ đề này!')),
      );
      Navigator.pop(context);
    }
  }
  void _handleAnalyze() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập câu của bạn trước khi kiểm tra!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _aiResponse = null;
    });

    try {
      final response = await _aiService.analyzeSentence(
        _controller.text.trim(),
        _currentWord.word,
        _scenario ?? "",
      );
      
      setState(() {
        _isAnalyzing = false;
        _aiResponse = response['result'];
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _aiResponse = " Lỗi: Không thể kết nối với AI Mentor. Vui lòng thử lại sau.\n($e)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Luyện viết với AI',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thẻ từ vựng mục tiêu ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Từ vựng mục tiêu',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentWord.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(${_currentWord.wordType}) ${_currentWord.definitionVi}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── AI Prompt / Scenario ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Thử thách từ AI Mentor:',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(LucideIcons.rotateCcw, color: Colors.purple, size: 18),
                        onPressed: _isLoadingScenario ? null : _fetchScenario,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingScenario)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple)),
                    ))
                  else
                    Text(
                      _scenario ?? 'Đang tải thử thách...',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Viết câu của bạn:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // ── Ô nhập liệu ──────────────────────────────────────────────────
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập câu của bạn tại đây...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _handleAnalyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: _isAnalyzing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(LucideIcons.wand2),
                label: Text(_isAnalyzing ? 'AI đang phân tích...' : 'AI Kiểm tra câu'),
              ),
            ),

            const SizedBox(height: 32),

            // ── Kết quả AI ──────────────────────────────────────────────────
            if (_aiResponse != null) ...[
              _buildResultSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _handleNextWord,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(LucideIcons.arrowRight),
                  label: const Text('Học từ tiếp theo'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Biến để quản lý trạng thái đóng/mở của các section
  final Map<String, bool> _expandedSections = {
    'SCORE': true,
    'ANALYSIS': false,
    'REVISION': true,
    'SAMPLE': true,
    'EXPLANATION': false,
  };

  Widget _buildResultSection() {
    final regExp = RegExp(r'### \[(SCORE|ANALYSIS|REVISION|SAMPLE|EXPLANATION)\]');
    final matches = regExp.allMatches(_aiResponse!).toList();
    
    Map<String, String> sectionMap = {};
    List<String> tags = matches.map((m) => m.group(1)!).toList();
    
    for (int i = 0; i < matches.length; i++) {
      int start = matches[i].end;
      int end = (i + 1 < matches.length) ? matches[i + 1].start : _aiResponse!.length;
      sectionMap[tags[i]] = _aiResponse!.substring(start, end).trim();
    }

    if (sectionMap.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider),
        ),
        child: MarkdownBody(data: _aiResponse!),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'PHÂN TÍCH TỪ AI MENTOR',
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 14, 
              letterSpacing: 1.2,
              color: AppColors.textSecondary
            ),
          ),
        ),
        ...sectionMap.entries.map((entry) {
          final tag = entry.key;
          final isExpanded = _expandedSections[tag] ?? false;
          
          IconData icon;
          String title;
          Color accentColor;
          Color bgColor;

          switch (tag) {
            case 'SCORE':
              icon = LucideIcons.trophy;
              title = 'Điểm đánh giá';
              accentColor = Colors.orange.shade700;
              bgColor = Colors.orange.shade50;
              break;
            case 'ANALYSIS':
              icon = LucideIcons.searchCode;
              title = 'Chi tiết lỗi sai';
              accentColor = Colors.blue.shade700;
              bgColor = Colors.blue.shade50;
              break;
            case 'REVISION':
              icon = LucideIcons.checkCircle2;
              title = 'Câu sửa lại';
              accentColor = Colors.teal.shade700;
              bgColor = Colors.teal.shade50;
              break;
            case 'SAMPLE':
              icon = LucideIcons.lightbulb;
              title = 'Câu mẫu nên học';
              accentColor = Colors.purple.shade700;
              bgColor = Colors.purple.shade50;
              break;
            case 'EXPLANATION':
              icon = LucideIcons.bookOpenCheck;
              title = 'Cấu trúc cần nhớ';
              accentColor = Colors.indigo.shade700;
              bgColor = Colors.indigo.shade50;
              break;
            default:
              icon = LucideIcons.info;
              title = 'Thông tin thêm';
              accentColor = Colors.grey.shade700;
              bgColor = Colors.grey.shade50;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Clickable)
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedSections[tag] = !isExpanded;
                    });
                  },
                  borderRadius: isExpanded 
                    ? const BorderRadius.vertical(top: Radius.circular(24))
                    : BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: isExpanded 
                        ? const BorderRadius.vertical(top: Radius.circular(24))
                        : BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: accentColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: accentColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                          color: accentColor.withOpacity(0.5),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                // Content (Animated visibility)
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: MarkdownBody(
                      data: entry.value,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: Colors.grey.shade800, height: 1.6, fontSize: 15),
                        listBullet: TextStyle(color: accentColor),
                        strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
