import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../home/section_title.dart';
import '../../../data/models/history_item_model.dart';
import 'history_row.dart';
import 'history_full_sheet.dart';

class HistorySection extends StatefulWidget {
  final List<HistoryItem> practiceItems;
  final List<HistoryItem> examItems;

  /// Số dòng hiển thị trước khi ẩn (mặc định 5)
  final int previewCount;

  const HistorySection({
    super.key,
    required this.practiceItems,
    required this.examItems,
    this.previewCount = 5,
  });

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<HistoryItem> get _currentItems =>
      _tabController.index == 0 ? widget.practiceItems : widget.examItems;

  bool get _hasMore => _currentItems.length > widget.previewCount;

  List<HistoryItem> get _visibleItems => _hasMore
      ? _currentItems.take(widget.previewCount).toList()
      : _currentItems;

  // ── Mở bottom sheet toàn bộ lịch sử ────────
  void _openFullSheet() {
    HistoryFullSheet.show(
      context,
      practiceItems: widget.practiceItems,
      examItems: widget.examItems,
      initialTab: _tabController.index, // giữ nguyên tab đang xem
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Lịch sử'),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTabBar(),
                const Divider(height: 1, color: AppColors.border),
                _buildList(),
              ],
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
      tabs: const [
        Tab(text: 'Luyện tập'),
        Tab(text: 'Thi'),
      ],
    );
  }

  // ── Danh sách preview ────────────────────────
  Widget _buildList() {
    if (_currentItems.isEmpty) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ..._visibleItems.map((item) => Column(
            children: [
              HistoryRow(item: item),
              if (item != _visibleItems.last)
                const Divider(height: 1, color: AppColors.border),
            ],
          )),
          if (_hasMore) _buildSeeMoreButton(),
          if (!_hasMore) const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Nút "Xem thêm" → mở sheet ───────────────
  Widget _buildSeeMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: GestureDetector(
        onTap: _openFullSheet,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem tất cả ${_currentItems.length} hoạt động',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 36,
                color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'Chưa có lịch sử',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}