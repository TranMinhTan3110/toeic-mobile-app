import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../widgets/practice/practice_stats_card.dart';
import 'speaking_doing_screen.dart';

class SpeakingPrepScreen extends StatefulWidget {
  final SpeakingPartInfo part;

  /// Số câu đã làm + tiến độ — truyền từ DB/provider
  final int totalDone;
  final int correct;
  final double progress;

  const SpeakingPrepScreen({
    super.key,
    required this.part,
    this.totalDone = 0,
    this.correct = 0,
    this.progress = 0,
  });

  @override
  State<SpeakingPrepScreen> createState() => _SpeakingPrepScreenState();
}

class _SpeakingPrepScreenState extends State<SpeakingPrepScreen> {
  static const List<int> _questionOptions = [5, 10, 15, 20];

  late int _selectedCount;
  bool _examMode = false;

  @override
  void initState() {
    super.initState();
    _selectedCount = widget.part.defaultQuestionCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Thẻ thống kê ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PracticeStatsCard(
                      icon: widget.part.icon,
                      totalDone: widget.totalDone,
                      correct: widget.correct,
                      progress: widget.progress,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 20),

                  // ── Card mô tả câu hỏi ───────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDescriptionCard(),
                  ),

                  const SizedBox(height: 20),

                  // ── Nâng cấp CTA ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildUpgradeRow(),
                  ),

                  const SizedBox(height: 24),

                  // ── Cài đặt: số câu + chế độ ─────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSettings(),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Nút bắt đầu cố định dưới ──────────────
          _buildStartButton(context),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.part.titleVi,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Card mô tả Câu hỏi ──────────────────────────────────────────────────
  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề "Câu hỏi" có gạch chân
          Text(
            'Câu hỏi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Tiếng Anh
          Text(
            widget.part.descriptionEn,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),
          // Tiếng Việt
          Text(
            widget.part.descriptionVi,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // ── Dòng Nâng cấp ───────────────────────────────────────────────────────
  Widget _buildUpgradeRow() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        children: [
          TextSpan(
            text: 'Nâng cấp',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
          const TextSpan(
            text: ' để tải toàn bộ bài tập về máy, '
                'tải dữ liệu nhanh hơn, ổn định hơn',
          ),
        ],
      ),
    );
  }

  // ── Cài đặt ─────────────────────────────────────────────────────────────
  Widget _buildSettings() {
    return Column(
      children: [
        // Số câu hỏi
        _SettingRow(
          label: 'Số câu hỏi:',
          trailing: _buildQuestionDropdown(),
        ),
        const SizedBox(height: 16),
        // Chế độ kiểm tra
        _SettingRow(
          label: 'Chế độ kiểm tra:',
          trailing: Switch(
            value: _examMode,
            onChanged: (v) => setState(() => _examMode = v),
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCount,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 20),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          onChanged: (v) => setState(() => _selectedCount = v!),
          items: _questionOptions
              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
              .toList(),
        ),
      ),
    );
  }

  // ── Nút Bắt đầu ─────────────────────────────────────────────────────────
  Widget _buildStartButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8F0), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpeakingDoingScreen(
                  part: widget.part,
                  questionCount: _selectedCount,
                  examMode: _examMode,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            'Bắt đầu nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget hàng cài đặt dùng lại ────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _SettingRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // thay spaceBetween
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12), // chỉnh khoảng cách tùy ý
        trailing,
      ],
    );
  }
}
