import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/speaking_provider.dart';
import '../../screens/speaking/speaking_history_screen.dart';
import 'speaking_history_card.dart';

class SpeakingHistorySection extends StatelessWidget {
  const SpeakingHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Lịch sử luyện tập',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SpeakingHistoryScreen(),
                    ),
                  );
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Consumer<SpeakingProvider>(
          builder: (context, provider, child) {
            if (provider.isHistoryLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final allItems = provider.historyItems;
            if (allItems.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Chưa có lịch sử luyện tập.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final items = allItems.take(3).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: items
                    .map((item) => SpeakingHistoryCard(item: item))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
