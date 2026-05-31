import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/speaking_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/speaking/speaking_history_card.dart';

class SpeakingHistoryScreen extends StatefulWidget {
  const SpeakingHistoryScreen({super.key});

  @override
  State<SpeakingHistoryScreen> createState() => _SpeakingHistoryScreenState();
}

class _SpeakingHistoryScreenState extends State<SpeakingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpeakingProvider>().fetchHistory(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Lịch sử Speaking',
        centerTitle: true,
        actions: [
          AppBarIconAction(
            icon: Icons.refresh_rounded,
            onTap: () => context.read<SpeakingProvider>().fetchHistory(
              forceRefresh: true,
            ),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Consumer<SpeakingProvider>(
        builder: (context, provider, child) {
          if (provider.isHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final items = provider.historyItems;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lịch sử luyện tập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy bắt đầu làm bài Speaking để lưu lại tiến độ học của bạn!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                SpeakingHistoryCard(item: items[index]),
          );
        },
      ),
    );
  }
}
