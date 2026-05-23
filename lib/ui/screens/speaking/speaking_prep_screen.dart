import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../../providers/speaking_provider.dart';
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
  late int _selectedCount;
  List<int> _questionOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedCount = widget.part.defaultQuestionCount;

    // Tải dữ liệu để biết tổng số câu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpeakingProvider>().fetchQuestionsByPart(widget.part.partNumber).then((_) {
        if (mounted) {
          final total = context.read<SpeakingProvider>().getQuestionsForPart(widget.part.partNumber).length;
          setState(() {
            _generateOptions(total);
          });
        }
      });
    });
  }

  void _generateOptions(int total) {
    if (total <= 0) {
      _questionOptions = [widget.part.defaultQuestionCount];
      _selectedCount = widget.part.defaultQuestionCount;
      return;
    }
    
    List<int> options = [];
    // Bước nhảy 2: 2, 4, 6...
    for (int i = 2; i <= total; i += 2) {
      options.add(i);
    }
    
    // Đảm bảo số lượng lớn nhất luôn có mặt nếu là số lẻ
    if (total > 0 && !options.contains(total)) {
      options.add(total);
    }

    _questionOptions = options;
    // Mặc định chọn số câu cao nhất
    _selectedCount = total;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeakingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: provider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

                  const SizedBox(height: 32),

                  // ── Cài đặt: số câu ─────────────
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
          Text(
            widget.part.descriptionEn,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildSettings() {
    return Column(
      children: [
        _SettingRow(
          label: 'Số câu hỏi:',
          trailing: _buildQuestionDropdown(),
        ),
      ],
    );
  }

  Widget _buildQuestionDropdown() {
    if (_questionOptions.isEmpty) return const SizedBox.shrink();
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
                  examMode: false,
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

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _SettingRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}
