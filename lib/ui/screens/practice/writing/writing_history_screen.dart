import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/writing_provider.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/writing/writing_history_section.dart';

class WritingHistoryScreen extends StatefulWidget {
  const WritingHistoryScreen({super.key});

  @override
  State<WritingHistoryScreen> createState() => _WritingHistoryScreenState();
}

class _WritingHistoryScreenState extends State<WritingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WritingProvider>().fetchHistory(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Lịch sử Writing',
        centerTitle: true,
        actions: [
          AppBarIconAction(
            icon: Icons.refresh_rounded,
            onTap: () => context.read<WritingProvider>().fetchHistory(
              forceRefresh: true,
            ),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Consumer<WritingProvider>(
          builder: (context, provider, child) {
            if (provider.isHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                      onPressed: () =>
                          provider.fetchHistory(forceRefresh: true),
                    ),
                  ],
                ),
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
                      color: AppColors.textHint.withValues(alpha: 0.5),
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
                      'Hãy bắt đầu làm bài Writing để lưu lại tiến độ học của bạn!',
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
              itemCount: items.length,
              itemBuilder: (context, index) {
                return WritingHistoryCard(item: items[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
