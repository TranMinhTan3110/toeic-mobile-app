import 'package:flutter/material.dart';

class BoldTextLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;

  const BoldTextLabel({super.key, required this.text, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
