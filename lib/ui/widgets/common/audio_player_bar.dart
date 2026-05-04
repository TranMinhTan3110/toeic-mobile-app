import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Audio player bar dùng trong màn hình làm bài nghe.
class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.elapsed,
    required this.total,
    required this.onPlayPause,
    this.onRewind,
    this.onForward,
  });

  final bool isPlaying;
  final double progress;
  final String elapsed;
  final String total;
  final VoidCallback onPlayPause;
  final VoidCallback? onRewind;
  final VoidCallback? onForward;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _Btn(
              icon: Icons.replay_5_rounded,
              onTap: onRewind ?? () {}),
          const SizedBox(width: 8),
          _Btn(
            icon: isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onTap: onPlayPause,
            size: 28,
          ),
          const SizedBox(width: 8),
          _Btn(
              icon: Icons.forward_5_rounded,
              onTap: onForward ?? () {}),
          const SizedBox(width: 10),
          Text(elapsed,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primaryLighter,
                thumbColor: AppColors.primary,
              ),
              child: Slider(value: progress, onChanged: (_) {}),
            ),
          ),
          const SizedBox(width: 8),
          Text(total,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap, this.size = 22});
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: AppColors.textSecondary, size: size),
    );
  }
}
