import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final drift = _controller.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              _GlowBlob(
                color: const Color(0xFF34D399),
                alignment: Alignment(
                  -0.9 + drift * 0.3,
                  -0.65 + drift * 0.15,
                ),
              ),
              _GlowBlob(
                color: const Color(0xFF22D3EE),
                alignment: Alignment(0.85 - drift * 0.25, -0.05 + drift * 0.2),
              ),
              _GlowBlob(
                color: const Color(0xFFA78BFA),
                alignment: Alignment(
                  -0.3 + drift * 0.25,
                  0.9 - drift * 0.15,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.alignment});

  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 100,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}
