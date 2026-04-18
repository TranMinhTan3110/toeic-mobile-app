import 'package:flutter/material.dart';
import 'package:toeicmobileapp/ui/widgets/practice/practice_bottom_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/cards/reusable_image_card.dart';
import '../../widgets/inputs/description_input_box.dart';
import '../../widgets/shared/bold_text_label.dart';

class PictureDescriptionTestScreen extends StatefulWidget {
  const PictureDescriptionTestScreen({super.key});

  @override
  State<PictureDescriptionTestScreen> createState() =>
      _PictureDescriptionTestScreenState();
}

class _PictureDescriptionTestScreenState
    extends State<PictureDescriptionTestScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Câu 1',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mô tả tranh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            ReusableImageCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
            ),

            const SizedBox(height: 24),

            const BoldTextLabel(text: 'Coffee / Empty'),

            const SizedBox(height: 16),

            DescriptionInputBox(
              controller: _controller,
              hintText: 'Viết câu trả lời của bạn...',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      bottomNavigationBar: PracticeBottomBar(
        onSubmit: () {
          print(_controller.text);
        },
        onNext: () {
          print('Next question');
        },
      ),
    );
  }
}
