import 'package:flutter/material.dart';

import '../../models/task.dart';

class TaskReviewStep extends StatelessWidget {
  const TaskReviewStep({
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.hasTime,
    required this.reminderEnabled,
    required this.reminderMinutesBefore,
    required this.onEditStep,
    required this.onSaveAndAddAnother,
    super.key,
  });

  final TaskCategory category;
  final String title;
  final String description;
  final Priority priority;
  final DateTime? dueDate;
  final bool hasTime;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final ValueChanged<int> onEditStep;
  final VoidCallback onSaveAndAddAnother;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review your task',
          style: TextStyle(
            color: Color(0xFFEEECFF),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1715),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _reviewRow(
                icon: category.icon,
                color: category.color,
                child: _tag(category.label, category.color),
                onTap: () => onEditStep(0),
              ),
              const SizedBox(height: 15),
              _reviewRow(
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF34D399),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.trim().isEmpty ? 'Task title' : title.trim(),
                      style: const TextStyle(
                        color: Color(0xFFEEECFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (description.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        description.trim(),
                        style: const TextStyle(
                          color: Color(0xFFA9A6C8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () => onEditStep(1),
              ),
              const SizedBox(height: 15),
              _reviewRow(
                icon: Icons.flag_rounded,
                color: _priorityColor(priority),
                child: _tag(
                  '${priority.name[0].toUpperCase()}${priority.name.substring(1)} priority',
                  _priorityColor(priority),
                ),
                onTap: () => onEditStep(2),
              ),
              const SizedBox(height: 15),
              _reviewRow(
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF22D3EE),
                child: _tag(
                  dueDate == null
                      ? 'No due date'
                      : '${_formatDate(dueDate!)}${hasTime ? ' · ${_formatTime(dueDate!)}' : ''}',
                  const Color(0xFF22D3EE),
                ),
                onTap: () => onEditStep(3),
              ),
              if (hasTime && dueDate != null) ...[
                const SizedBox(height: 15),
                _reviewRow(
                  icon: Icons.notifications_active_rounded,
                  color: const Color(0xFF22D3EE),
                  child: _tag(
                    reminderEnabled
                        ? switch (reminderMinutesBefore) {
                            10 => 'Reminder: 10 min before',
                            60 => 'Reminder: 1 hour before',
                            _ => 'Reminder: At due time',
                          }
                        : 'Reminder: Off',
                    const Color(0xFF22D3EE),
                  ),
                  onTap: () => onEditStep(3),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: onSaveAndAddAnother,
            child: const Text(
              'Save & add another',
              style: TextStyle(
                color: Color(0xFF34D399),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewRow({
    required IconData icon,
    required Color color,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 11),
            Expanded(child: child),
            const Icon(
              Icons.edit_rounded,
              color: Color(0xFFA9A6C8),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );

  Color _priorityColor(Priority value) => switch (value) {
    Priority.low => const Color(0xFF34D399),
    Priority.medium => const Color(0xFFFBBF24),
    Priority.high => const Color(0xFFFB7185),
  };

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }
}
