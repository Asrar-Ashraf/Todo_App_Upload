import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/task.dart';

class TaskCategoryStep extends StatelessWidget {
  const TaskCategoryStep({
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final TaskCategory selectedCategory;
  final ValueChanged<TaskCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What kind of task is it?',
          style: TextStyle(
            color: Color(0xFFEEECFF),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose a type to make your task easier to find.',
          style: TextStyle(color: Color(0xFFA9A6C8), fontSize: 13),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: 1.14,
          ),
          itemCount: TaskCategory.values.length,
          itemBuilder: (context, index) {
              final category = TaskCategory.values[index];
              final selected = category == selectedCategory;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(category);
                },
                child: AnimatedScale(
                  scale: selected ? 1.025 : 1,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1715),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? category.color
                            : Colors.white.withValues(alpha: 0.08),
                        width: selected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(
                            color: category.color.withValues(alpha: 0.15),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(category.icon, color: category.color, size: 29),
                            const SizedBox(height: 9),
                            Text(
                              category.label,
                              style: const TextStyle(
                                color: Color(0xFFEEECFF),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              category.hint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFA9A6C8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        if (selected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: category.color,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(
                duration: 260.ms,
                delay: Duration(milliseconds: index * 45),
              ).slideY(
                begin: 0.08,
                duration: 300.ms,
                curve: Curves.easeOutCubic,
                delay: Duration(milliseconds: index * 45),
              );
          },
        ),
      ],
    );
  }
}
