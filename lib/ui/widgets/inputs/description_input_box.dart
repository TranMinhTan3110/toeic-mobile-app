import 'package:flutter/material.dart';

class DescriptionInputBox extends StatelessWidget {
  final String? hintText;
  final EdgeInsetsGeometry? margin;

  const DescriptionInputBox({super.key, this.hintText, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16.0),
      child: TextField(
        maxLines: null,
        minLines: 3,
        decoration: InputDecoration(
          hintText: hintText ?? "Ví dụ: trả lời của bạn",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}
