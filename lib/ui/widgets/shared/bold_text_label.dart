import 'package:flutter/material.dart';

class BoldTextLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;

  const BoldTextLabel({super.key, required this.text, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
