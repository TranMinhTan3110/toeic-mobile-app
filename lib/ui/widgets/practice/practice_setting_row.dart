import 'package:flutter/material.dart';

class PracticeSettingsRow extends StatelessWidget {
  const PracticeSettingsRow({
    super.key,
    required this.value,
    required this.options,
    required this.isCheckMode,
    required this.onChanged,
    required this.onToggleCheck,
  });

  final int value;
  final List<int> options;
  final bool isCheckMode;
  final Function(int) onChanged;
  final Function(bool) onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text('Số câu hỏi:'),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: value,
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Kiểm tra:'),
            Switch(value: isCheckMode, onChanged: onToggleCheck),
          ],
        ),
      ],
    );
  }
}
