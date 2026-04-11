import 'package:flutter/material.dart';
import 'dart:io';

class ReusableImageCard extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const ReusableImageCard({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 250.0,
        padding: const EdgeInsets.all(12.0),
        color: Colors.white,
        child: imagePath.isNotEmpty
            ? Image.asset(imagePath, fit: BoxFit.contain)
            : const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
      ),
    );
  }
}
