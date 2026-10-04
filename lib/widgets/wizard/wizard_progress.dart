import 'package:flutter/material.dart';

class WizardProgress extends StatelessWidget {
  const WizardProgress({required this.currentStep, super.key});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'CREATE TASK',
              style: TextStyle(
                color: Color(0xFFA9A6C8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Text(
              'Step $currentStep of 5',
              style: const TextStyle(
                color: Color(0xFFEEECFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: currentStep / 5),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF34D399)),
            ),
          ),
        ),
      ],
    );
  }
}
