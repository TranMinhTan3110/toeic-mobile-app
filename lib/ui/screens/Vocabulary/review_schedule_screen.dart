import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/review_schedule_item.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'vocabulary_review_screen.dart';
import 'package:dio/dio.dart';

class ReviewScheduleScreen extends StatefulWidget {
  const ReviewScheduleScreen({super.key});

  @override
  State<ReviewScheduleScreen> createState() => _ReviewScheduleScreenState();
}

class _ReviewScheduleScreenState extends State<ReviewScheduleScreen> {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  List<ReviewScheduleItem> _items = [];
  bool _isLoading = true;
  String? _error;
  bool _showMastered = false; // Ẩn từ 100% mặc định

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await _authService.getIdToken();
      final response = await _dio.get(
        '${AppConstants.baseUrl}/vocabularies/review-schedule',
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      final List<dynamic> data = response.data;
      setState(() {
        _items = data.map((e) => ReviewScheduleItem.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Lọc danh sách theo toggle "Hiện thành thạo"
  List<ReviewScheduleItem> get _filteredItems =>
      _showMastered ? _items : _items.where((i) => !i.isMastered).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final dueItems = filtered.where((i) => i.isDue).toList();
    final masteredCount = _items.where((i) => i.isMastered).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Lịch ôn tập', centerTitle: true),
      bottomNavigationBar: _isLoading || _error != null
          ? null
          : _buildBottomBar(dueItems),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? _buildError()
          : _items.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                children: [
                  // ── Tóm tắt + Toggle ────────────────────────────
                  _buildHeaderRow(dueItems.length, masteredCount),
                  const SizedBox(height: 16),

                  // ── Các nhóm thời gian ───────────────────────────
                  ..._buildGroupedSections(filtered),
                ],
              ),
            ),
    );
  }

  /// Build các section nhóm theo khoảng thời gian
  List<Widget> _buildGroupedSections(List<ReviewScheduleItem> items) {
    final groups = <String, List<ReviewScheduleItem>>{
      'overdue': [],
      'today': [],
      'tomorrow': [],
      'thisWeek': [],
      'later': [],
    };

    for (final item in items) {
      final d = item.daysUntilDue;
      if (d < 0) {
        groups['overdue']!.add(item);
      } else if (d == 0)
        groups['today']!.add(item);
      else if (d == 1)
        groups['tomorrow']!.add(item);
      else if (d <= 7)
        groups['thisWeek']!.add(item);
      else
        groups['later']!.add(item);
    }

    final sections = <Widget>[];

    void addSection(String key, String title, Color color, IconData icon) {
      final list = groups[key]!;
      if (list.isEmpty) return;
      sections.add(
        _CollapsibleSection(
          title: '$title (${list.length})',
          color: color,
          icon: icon,
          defaultExpanded: key == 'overdue' || key == 'today',
          children: list.map((item) => _buildCard(item)).toList(),
        ),
      );
      sections.add(const SizedBox(height: 12));
    }

    addSection('overdue', 'Quá hạn', AppColors.error, Boxicons.bx_error_circle);
    addSection('today', 'Hôm nay', AppColors.warning, Boxicons.bx_time);
    addSection(
      'tomorrow',
      'Ngày mai',
      AppColors.info,
      Boxicons.bx_calendar_check,
    );
    addSection('thisWeek', 'Tuần này', AppColors.primary, Boxicons.bx_calendar);
    addSection(
      'later',
      'Sau này',
      AppColors.textSecondary,
      Boxicons.bx_calendar_alt,
    );

    if (sections.isEmpty) {
      sections.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Không có từ nào để hiển thị',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
        ),
      );
    }
    return sections;
  }

  Widget _buildHeaderRow(int dueCount, int masteredCount) {
    return Row(
      children: [
        // Badge "Cần ôn"
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: dueCount > 0
                  ? AppColors.error.withOpacity(0.08)
                  : AppColors.greenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  dueCount > 0 ? Boxicons.bx_time : Boxicons.bx_check_circle,
                  color: dueCount > 0 ? AppColors.error : AppColors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  dueCount > 0 ? '$dueCount cần ôn' : 'Tất cả đã ôn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dueCount > 0 ? AppColors.error : AppColors.green,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Toggle ẩn/hiện từ thành thạo
        GestureDetector(
          onTap: () => setState(() => _showMastered = !_showMastered),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _showMastered
                  ? AppColors.green.withOpacity(0.12)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showMastered ? AppColors.green : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showMastered ? Boxicons.bxs_star : Boxicons.bx_star,
                  color: _showMastered ? AppColors.green : AppColors.textHint,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Thành thạo ($masteredCount)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _showMastered ? AppColors.green : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(List<ReviewScheduleItem> dueItems) {
    final hasDue = dueItems.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: hasDue
          ? ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VocabularyReviewScreen(),
                  ),
                );
                _load();
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                'Bắt đầu ôn tập (${dueItems.length} từ)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.green,
                    size: 22,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chưa có từ nào đến hạn hôm nay',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(ReviewScheduleItem item) {
    final isDue = item.isDue;
    final days = item.daysUntilDue;

    String daysLabel;
    Color daysColor;
    if (isDue) {
      daysLabel = days == 0 ? 'Hôm nay' : 'Quá hạn ${(-days)} ngày';
      daysColor = AppColors.error;
    } else {
      daysLabel = days == 1 ? 'Ngày mai' : 'Còn $days ngày';
      daysColor = days <= 3 ? AppColors.warning : AppColors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDue ? AppColors.error.withOpacity(0.25) : AppColors.divider,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mastery %
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isMastered
                  ? AppColors.green.withOpacity(0.12)
                  : AppColors.primarySurface,
            ),
            child: Center(
              child: Text(
                '${item.masteryLevel}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: item.isMastered ? AppColors.green : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Word
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.word,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.wordType,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  item.definitionVi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Days badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: daysColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: daysColor.withOpacity(0.3)),
            ),
            child: Text(
              daysLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: daysColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Boxicons.bx_book_open, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'Chưa có từ nào đã học',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy học flashcard để bắt đầu!',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Boxicons.bx_wifi_off, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Collapsible Section Widget ────────────────────────────────────────────────
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final bool defaultExpanded;
  final List<Widget> children;

  const _CollapsibleSection({
    required this.title,
    required this.color,
    required this.icon,
    required this.defaultExpanded,
    required this.children,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.defaultExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bấm để mở/đóng
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: widget.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Nội dung
        if (_expanded) ...[const SizedBox(height: 6), ...widget.children],
      ],
    );
  }
}
