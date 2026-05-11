import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Report dialog (dấu chấm than) ────────────────────────────────────────────

void showReportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Báo lỗi câu hỏi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn loại lỗi:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ...[
              'Sai đáp án',
              'Nội dung không rõ ràng',
              'Lỗi âm thanh / hình ảnh',
              'Khác',
            ].map((label) => _ReportOption(label: label)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Gửi báo cáo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReportOption extends StatelessWidget {
  const _ReportOption({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.radio_button_unchecked_rounded,
        color: AppColors.primary,
        size: 20,
      ),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

// ── Settings dialog (bánh răng) ───────────────────────────────────────────────

void showPracticeSettingsDialog(
  BuildContext context, {
  required double playbackSpeed,
  required bool autoPlay,
  required bool showTranscript,
  required ValueChanged<double> onSpeedChanged,
  required ValueChanged<bool> onAutoPlayChanged,
  required ValueChanged<bool> onTranscriptChanged,
}) {
  showDialog(
    context: context,
    builder: (_) => _SettingsDialog(
      playbackSpeed: playbackSpeed,
      autoPlay: autoPlay,
      showTranscript: showTranscript,
      onSpeedChanged: onSpeedChanged,
      onAutoPlayChanged: onAutoPlayChanged,
      onTranscriptChanged: onTranscriptChanged,
    ),
  );
}

class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog({
    required this.playbackSpeed,
    required this.autoPlay,
    required this.showTranscript,
    required this.onSpeedChanged,
    required this.onAutoPlayChanged,
    required this.onTranscriptChanged,
  });

  final double playbackSpeed;
  final bool autoPlay;
  final bool showTranscript;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onTranscriptChanged;

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late double _speed;
  late bool _autoPlay;
  late bool _transcript;

  @override
  void initState() {
    super.initState();
    _speed = widget.playbackSpeed;
    _autoPlay = widget.autoPlay;
    _transcript = widget.showTranscript;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Cài đặt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Speed
            const Text(
              'Tốc độ phát âm thanh',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
                final selected = _speed == speed;
                return GestureDetector(
                  onTap: () => setState(() => _speed = speed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${speed}x',
                      style: TextStyle(
                        color: selected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Auto play
            _SwitchRow(
              icon: Icons.play_circle_outline_rounded,
              label: 'Tự động phát',
              value: _autoPlay,
              onChanged: (v) => setState(() => _autoPlay = v),
            ),
            const Divider(color: AppColors.divider, height: 20),

            // Show transcript
            _SwitchRow(
              icon: Icons.subtitles_outlined,
              label: 'Hiện phụ đề',
              value: _transcript,
              onChanged: (v) => setState(() => _transcript = v),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSpeedChanged(_speed);
                  widget.onAutoPlayChanged(_autoPlay);
                  widget.onTranscriptChanged(_transcript);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
