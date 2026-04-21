//dùng để test 3 widget: ReusableImageCard, BoldTextLabel, DescriptionInputBox
import 'package:flutter/material.dart';
import '../widgets/cards/reusable_image_card.dart';
import '../shared/bold_text_label.dart';
import '../widgets/inputs/description_input_box.dart';

void main() {
  runApp(const MaterialApp(home: TestScreen()));
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Đường dẫn đến hình ảnh trên máy tính (cần test/đổi hình thì thêm hình vào assets và vào pubspec.yaml thêm đường dẫn)
    String imagePath = 'assets/images/cassette_image.jpg';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4DB6AC),
        leading: const Icon(Icons.arrow_back_ios, color: Colors.white),
        title: const Text('Câu 1', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        actions: const [
          Icon(Icons.info_outline, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.settings, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.favorite_border, color: Colors.white),
          SizedBox(width: 16),
          Center(
            child: Text(
              'Giải thích',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 20, color: const Color(0xFF00695C)),

            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Mô tả tranh",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),

            // Widget 1: Box chứa hình ảnh
            ReusableImageCard(imagePath: imagePath),

            // Widget 2: Chữ đậm dưới hình ảnh
            const BoldTextLabel(text: "Cassette / Damage"),

            // Widget 3: Input box
            const DescriptionInputBox(),
          ],
        ),
      ),
    );
  }
}
