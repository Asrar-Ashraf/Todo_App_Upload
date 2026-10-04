import 'package:flutter/material.dart';

const _green = Color(0xFF34D399);
const _cyan = Color(0xFF22D3EE);
const _muted = Color(0xFFA9A6C8);

class EmptyState extends StatefulWidget {
  const EmptyState({required this.hasTasks, super.key});

  final bool hasTasks;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);
  late final Animation<double> _float = Tween<double>(
    begin: 0,
    end: -9,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 250,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _float,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _float.value),
            child: child,
          ),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green.withValues(alpha: 0.1),
              border: Border.all(color: _cyan.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.checklist_rounded, color: _green, size: 36),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          widget.hasTasks
              ? 'No matching tasks'
              : 'No tasks yet. Tap + to add one',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFEEECFF),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your next win is one task away.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    ),
  );
}
