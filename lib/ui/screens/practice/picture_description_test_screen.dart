import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PictureDescriptionTestScreen extends StatefulWidget {
  const PictureDescriptionTestScreen({super.key});

  @override
  State<PictureDescriptionTestScreen> createState() =>
      _PictureDescriptionTestScreenState();
}

class _PictureDescriptionTestScreenState
    extends State<PictureDescriptionTestScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Tạo AppBar riêng cho màn hình thi vì có nhiều icon đặc thù
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Câu 1',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: () {
              // TODO: Xử lý xem thông tin
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Xử lý mở cài đặt
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Xử lý lưu câu hỏi (tym)
            },
          ),
          TextButton(
            onPressed: () {
              // TODO: Xử lý xem giải thích
            },
            child: const Text(
              'Giải thích',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề phần thi
            const Text(
              'Mô tả tranh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Khung chứa hình ảnh
            _buildImageBox(),

            const SizedBox(height: 24),

            // Từ khóa gợi ý (Keywords)
            const Center(
              child: Text(
                'Coffee / Empty',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Khung nhập câu trả lời
            _buildInputArea(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      // Thanh bottom navigation phụ để chuyển câu hỏi (bạn có thể tùy chỉnh lại)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Xử lý nộp bài
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Nộp bài',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý qua câu tiếp theo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Câu tiếp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS CON ---

  /// Widget hiển thị vùng chứa hình ảnh
  Widget _buildImageBox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // Dùng Image.network làm mẫu, bạn đổi thành Image.asset nếu dùng ảnh local
        child: Image.network(
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=800&auto=format&fit=crop', // Hình ly cà phê minh họa
          fit: BoxFit.cover,
          height: 250,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 250,
              color: AppColors.surfaceVariant,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 50,
                  color: AppColors.textHint,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget hiển thị khung nhập liệu
  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _answerController,
        maxLines: 5, // Tương đương độ cao của box nhập liệu
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Viết câu trả lời của bạn...',
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontStyle: FontStyle.italic,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
