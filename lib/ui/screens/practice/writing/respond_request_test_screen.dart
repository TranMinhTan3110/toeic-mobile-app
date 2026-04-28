import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/bold_text_label.dart';
import '../../../widgets/inputs/description_input_box.dart';
import '../../../widgets/practice/practice_bottom_bar.dart';
import '../../../widgets/cards/email_card.dart';

class RespondRequestTestScreen extends StatefulWidget {
  const RespondRequestTestScreen({super.key});

  @override
  State<RespondRequestTestScreen> createState() =>
      _RespondRequestTestScreenState();
}

class _RespondRequestTestScreenState extends State<RespondRequestTestScreen> {
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
              'Phản hồi yêu cầu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            EmailCard(
              from: 'John Smith',
              subject: 'Meeting Schedule',
              content:
                  'Hi,\n\n'
                  'I would like to schedule a meeting with you next week.\n'
                  'Are you available on Tuesday or Wednesday afternoon?\n\n'
                  'Please let me know your availability.\n\n'
                  'Best regards,\nJohn',
            ),

            const SizedBox(height: 24),

            const BoldTextLabel(text: 'Write a reply to this email'),

            const SizedBox(height: 16),

            DescriptionInputBox(
              controller: _controller,
              hintText: 'Viết email trả lời...',
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
