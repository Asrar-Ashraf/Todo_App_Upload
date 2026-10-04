import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _green = Color(0xFF34D399);
const _cyan = Color(0xFF22D3EE);
const _muted = Color(0xFFA9A6C8);

class ProgressHeader extends StatefulWidget {
  const ProgressHeader({
    required this.completed,
    required this.total,
    required this.progress,
    super.key,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  State<ProgressHeader> createState() => _ProgressHeaderState();
}

class _ProgressHeaderState extends State<ProgressHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );
  late final Animation<double> _pulse = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 1.1,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.1,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 1,
    ),
  ]).animate(_pulseController);

  bool get _isComplete => widget.total > 0 && widget.completed == widget.total;

  @override
  void didUpdateWidget(covariant ProgressHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasComplete =
        oldWidget.total > 0 && oldWidget.completed == oldWidget.total;
    if (_isComplete && !wasComplete) {
      _pulseController.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress.clamp(0.0, 1.0);
    final percentage = (progress * 100).round();
    final message = _isComplete
        ? 'All done! 🎉'
        : switch (progress) {
            0 => "Let's get started",
            >= 0.7 => 'Almost there!',
            _ => 'Keep going!',
          };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x990D1715),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) =>
                Transform.scale(scale: _pulse.value, child: child),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, value, _) => SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(76),
                      painter: _ProgressRingPainter(
                        value: value,
                        complete: _isComplete,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(colors: [_green, _cyan])
                              .createShader(bounds),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.completed} of ${widget.total} tasks done',
                  style: const TextStyle(
                    color: Color(0xFFEEECFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.value, required this.complete});

  final double value;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final center = rect.center;
    final radius = rect.width / 2;
    final background = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, background);
    final progressPaint = Paint()
      ..shader = complete
          ? const LinearGradient(colors: [_green, _cyan]).createShader(rect)
          : const LinearGradient(colors: [_green, _green]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -1.5708,
      6.2832 * value.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.complete != complete;
}
