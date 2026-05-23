import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/grammar_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/grammar_model.dart';

class GrammarLessonScreen extends StatefulWidget {
  final GrammarTopic topic;
  const GrammarLessonScreen({super.key, required this.topic});

  @override
  State<GrammarLessonScreen> createState() => _GrammarLessonScreenState();
}

class _GrammarLessonScreenState extends State<GrammarLessonScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isEarned = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<GrammarProvider>().fetchLesson(widget.topic.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _completeLesson() async {
    if (_submitting || _isEarned) return;

    setState(() => _submitting = true);

    try {
      debugPrint('⚡ [GrammarLessonScreen] Committing GrammarLessonComplete for ${widget.topic.id}');
      final result = await context.read<UserProvider>().recordActivity(
        activityType: 'GrammarLessonComplete',
        referenceId: widget.topic.id,
      );

      if (result != null) {
        setState(() => _isEarned = true);
        _showSuccessDialog(result.epAwarded);
      } else {
        // Nếu API trả về null nghĩa là bài học này hôm nay đã nhận EP rồi (hoặc lỗi nhẹ)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hôm nay bạn đã nhận EP cho bài học này rồi!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog(int epAwarded) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star particle effect decoration
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Boxicons.bxs_award,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tuyệt Vời! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bạn đã hoàn thành xuất sắc bài học:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.topic.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5EA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Boxicons.bxs_star, color: AppColors.success, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '+$epAwarded EP Tích Lũy',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng Dialog
                      Navigator.pop(this.context); // Trở về Hub
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Tiếp tục hành trình',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Bài Học Lý Thuyết',
      ),
      body: Consumer<GrammarProvider>(
        builder: (context, grammarProvider, child) {
          if (grammarProvider.isLoadingLesson) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (grammarProvider.lessonError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Boxicons.bx_error_circle, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải nội dung bài giảng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      grammarProvider.lessonError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => grammarProvider.fetchLesson(widget.topic.id),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tải lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final lesson = grammarProvider.currentLesson;
          if (lesson == null) {
            return const Center(
              child: Text('Bài giảng đang được cập nhật.'),
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 110), // padding bottom to avoid floating bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề chương học
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.divider, height: 1),
                      const SizedBox(height: 20),

                      // Nội dung Markdown với stylesheet cao cấp
                      MarkdownBody(
                        data: lesson.content,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF534AB7),
                            height: 1.5,
                          ),
                          h2: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            height: 1.4,
                          ),
                          p: const TextStyle(
                            fontSize: 14.5,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                          listBullet: const TextStyle(
                            fontSize: 14.5,
                            color: AppColors.primary,
                          ),
                          tableHead: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          tableBody: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          tableBorder: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquotePadding: const EdgeInsets.all(12),
                          blockquoteDecoration: BoxDecoration(
                            color: const Color(0xFFFFF6ED),
                            border: const Border(
                              left: BorderSide(color: AppColors.primary, width: 4),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquote: const TextStyle(
                            color: Color(0xFFC25100),
                            fontSize: 13.5,
                            fontStyle: FontStyle.normal,
                            height: 1.4,
                          ),
                          code: const TextStyle(
                            fontFamily: 'monospace',
                            backgroundColor: Colors.transparent,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Floating Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Đã đọc xong lý thuyết?',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Nhận điểm EP để tích luỹ streak.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (_scrollController.hasClients && _scrollController.offset > 0 || true) 
                            ? _completeLesson 
                            : null, // Cho phép bấm nhận điểm trực tiếp luôn để tiện test
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 1,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Xác Nhận & Nhận EP 🔥',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
