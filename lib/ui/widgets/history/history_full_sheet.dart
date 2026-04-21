import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/history_item_model.dart';
import 'history_row.dart';

class HistoryFullSheet extends StatefulWidget {
  final List<HistoryItem> practiceItems;
  final List<HistoryItem> examItems;

  /// Tab mở mặc định: 0 = Luyện tập, 1 = Thi
  final int initialTab;

  const HistoryFullSheet({
    super.key,
    required this.practiceItems,
    required this.examItems,
    this.initialTab = 0,
  });

  // ── Helper để mở sheet từ bất kỳ đâu ───────
  static void show(
      BuildContext context, {
        required List<HistoryItem> practiceItems,
        required List<HistoryItem> examItems,
        int initialTab = 0,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,         // cho phép chiếm đến 90% màn hình
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryFullSheet(
        practiceItems: practiceItems,
        examItems: examItems,
        initialTab: initialTab,
      ),
    );
  }

  @override
  State<HistoryFullSheet> createState() => _HistoryFullSheetState();
}

class _HistoryFullSheetState extends State<HistoryFullSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<HistoryItem> get _currentItems =>
      _tabController.index == 0 ? widget.practiceItems : widget.examItems;

  @override
  Widget build(BuildContext context) {
    // chiếm 88% chiều cao màn hình
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: maxHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildSheetHeader(context),
          _buildTabBar(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ── Drag handle ──────────────────────────────
  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ── Header: tiêu đề + đóng + số lượng ───────
  Widget _buildSheetHeader(BuildContext context) {
    final count = _currentItems.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch sử của bạn',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count hoạt động',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // nút đóng
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFE8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ──────────────────────────────────
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textMuted,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2.5),
        insets: EdgeInsets.symmetric(horizontal: 24),
      ),
      dividerColor: Colors.transparent,
      tabs: [
        Tab(text: 'Luyện tập (${widget.practiceItems.length})'),
        Tab(text: 'Thi (${widget.examItems.length})'),
      ],
    );
  }

  // ── Danh sách cuộn ──────────────────────────
  Widget _buildList() {
    if (_currentItems.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _currentItems.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: AppColors.border),
      itemBuilder: (_, i) => HistoryRow(item: _currentItems[i]),
    );
  }

  // ── Empty state ──────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textMuted.withOpacity(0.35),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có lịch sử',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}