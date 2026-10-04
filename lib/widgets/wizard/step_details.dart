import 'package:flutter/material.dart';

import '../../data/task_suggestions.dart';
import '../../models/task.dart';

class TaskDetailsStep extends StatelessWidget {
  const TaskDetailsStep({
    required this.titleController,
    required this.descriptionController,
    required this.category,
    required this.onChangeCategory,
    required this.onTitleChanged,
    this.titleError = false,
    this.shakeAnimation,
    this.showCategoryChange = true,
    this.showHeading = true,
    super.key,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TaskCategory category;
  final VoidCallback onChangeCategory;
  final ValueChanged<String> onTitleChanged;
  final bool titleError;
  final Animation<double>? shakeAnimation;
  final bool showCategoryChange;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final titleField = TextField(
      controller: titleController,
      maxLength: 80,
      autofocus: false,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      onChanged: onTitleChanged,
      style: const TextStyle(color: Color(0xFFEEECFF), fontSize: 15),
      decoration: _decoration(
        hint: 'What needs to get done?',
        icon: Icons.task_alt_rounded,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
          const Text(
            'Task details',
            style: TextStyle(
              color: Color(0xFFEEECFF),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 17),
        ],
        if (showCategoryChange) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              onPressed: onChangeCategory,
              avatar: Icon(category.icon, color: category.color, size: 16),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.label),
                  const SizedBox(width: 7),
                  const Text(
                    'Change',
                    style: TextStyle(color: Color(0xFF34D399), fontSize: 11),
                  ),
                ],
              ),
              backgroundColor: category.color.withValues(alpha: 0.08),
              side: BorderSide(color: category.color.withValues(alpha: 0.25)),
              labelStyle: const TextStyle(
                color: Color(0xFFEEECFF),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'QUICK PICKS',
          style: TextStyle(
            color: Color(0xFFA9A6C8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 37,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: taskSuggestions[category]!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 7),
            itemBuilder: (context, index) {
              final suggestion = taskSuggestions[category]![index];
              return ActionChip(
                onPressed: () {
                  titleController.value = TextEditingValue(
                    text: suggestion,
                    selection: TextSelection.collapsed(
                      offset: suggestion.length,
                    ),
                  );
                  onTitleChanged(suggestion);
                },
                label: Text(suggestion),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                backgroundColor: Colors.white.withValues(alpha: 0.045),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                labelStyle: const TextStyle(
                  color: Color(0xFFEEECFF),
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: shakeAnimation ?? const AlwaysStoppedAnimation(0),
          builder: (context, child) => Transform.translate(
            offset: Offset(shakeAnimation?.value ?? 0, 0),
            child: child,
          ),
          child: titleField,
        ),
        if (titleError)
          const Padding(
            padding: EdgeInsets.only(left: 13, top: 2),
            child: Text(
              'Please enter a task title',
              style: TextStyle(color: Color(0xFFFB7185), fontSize: 12),
            ),
          ),
        const SizedBox(height: 13),
        TextField(
          controller: descriptionController,
          maxLength: 300,
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(color: Color(0xFFEEECFF), fontSize: 14),
          decoration: _decoration(
            hint: 'Add a description (optional)',
            icon: Icons.notes_rounded,
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA9A6C8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFA9A6C8), size: 19),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.045),
      counterStyle: const TextStyle(color: Color(0xFFA9A6C8), fontSize: 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF34D399)),
      ),
    );
  }
}
