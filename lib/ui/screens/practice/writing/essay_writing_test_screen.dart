import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/cards/essay_prompt_card.dart';
import '../../../widgets/shared/bold_text_label.dart';
import '../../../widgets/inputs/description_input_box.dart';
import '../../../widgets/practice/practice_bottom_bar.dart';

class EssayWritingTestScreen extends StatefulWidget {
  const EssayWritingTestScreen({super.key});

  @override
  State<EssayWritingTestScreen> createState() => _EssayWritingTestScreenState();
}

class _EssayWritingTestScreenState extends State<EssayWritingTestScreen> {
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
        title: const Text('Câu 1'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Viết luận',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            const EssayPromptCard(
              prompt:
                  'Do you agree or disagree with the following statement? '
                  'It is better to work in a team than to work alone. '
                  'Use specific reasons and examples to support your answer.',
            ),

            const SizedBox(height: 24),

            const BoldTextLabel(text: 'Write your essay'),

            const SizedBox(height: 16),

            DescriptionInputBox(
              controller: _controller,
              hintText: 'Viết bài luận của bạn...',
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
