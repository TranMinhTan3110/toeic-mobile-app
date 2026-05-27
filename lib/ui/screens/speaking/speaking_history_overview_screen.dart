import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'speaking_history_review_screen.dart';

class SpeakingHistoryOverviewScreen extends StatelessWidget {
  final int partNumber;
  final String partTitle;
  
  const SpeakingHistoryOverviewScreen({
    super.key,
    required this.partNumber,
    required this.partTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tổng quan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: const SizedBox(),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Part $partNumber: $partTitle',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 3, // Giả sử đã làm 3 câu
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpeakingHistoryReviewScreen(
                          title: 'Câu ${index + 1}',
                          partNumber: partNumber,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Câu ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'The personnel managers have decided to make staff changes in the finance department...', // Transcript giả lập
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary, 
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Thanh banner màu cam dưới cùng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: const Color(0xFFFF8C42), 
            child: const Text(
              'Ấn vào từng câu để xem giải thích chi tiết',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
