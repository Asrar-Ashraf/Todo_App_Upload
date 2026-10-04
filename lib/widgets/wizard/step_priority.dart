import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/task.dart';

class TaskPriorityStep extends StatelessWidget {
  const TaskPriorityStep({
    required this.priority,
    required this.onSelected,
    this.compact = false,
    this.showHeading = true,
    super.key,
  });

  final Priority priority;
  final ValueChanged<Priority> onSelected;
  final bool compact;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    const labels = {
      Priority.low: ('Low', 'Can wait', Icons.south_rounded, Color(0xFF34D399)),
      Priority.medium: (
        'Medium',
        'Do it soon',
        Icons.remove_rounded,
        Color(0xFFFBBF24),
      ),
      Priority.high: (
        'High',
        'Urgent, do it first',
        Icons.priority_high_rounded,
        Color(0xFFFB7185),
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
          const Text(
            'How important is it?',
            style: TextStyle(
              color: Color(0xFFEEECFF),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
        for (final value in Priority.values) ...[
          if (value != Priority.low) SizedBox(height: compact ? 8 : 12),
          Builder(
            builder: (context) {
              final info = labels[value]!;
              final selected = priority == value;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: compact ? 10 : 17,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? info.$4.withValues(alpha: 0.10)
                        : const Color(0xFF0D1715),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? info.$4
                          : Colors.white.withValues(alpha: 0.08),
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: compact ? 34 : 42,
                        height: compact ? 34 : 42,
                        decoration: BoxDecoration(
                          color: info.$4.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(info.$3, color: info.$4, size: 20),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.$1,
                              style: TextStyle(
                                color: info.$4,
                                fontSize: compact ? 13 : 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (!compact) ...[
                              const SizedBox(height: 3),
                              Text(
                                info.$2,
                                style: const TextStyle(
                                  color: Color(0xFFA9A6C8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_circle_rounded, color: info.$4),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
