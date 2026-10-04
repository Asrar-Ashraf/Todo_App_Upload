import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_snackbar.dart';
import 'task_form_sheet.dart';

const _green = Color(0xFF34D399);
const _amber = Color(0xFFFBBF24);
const _red = Color(0xFFFB7185);
const _muted = Color(0xFFA9A6C8);
const _pink = Color(0xFFF472B6);

class TaskCard extends StatefulWidget {
  const TaskCard({required this.task, this.inCompletedTab = false, super.key});

  final Task task;
  final bool inCompletedTab;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  late final AnimationController _pressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _pressScale = Tween<double>(begin: 1, end: 0.97)
      .animate(
        CurvedAnimation(parent: _pressController, curve: Curves.easeOutBack),
      );
  late final AnimationController _sparkleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final AnimationController _favoriteController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final AnimationController _bubbleNudgeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.task.isDone && widget.task.isDone) {
      _sparkleController.forward(from: 0);
    }
    if (!oldWidget.task.isFavorite && widget.task.isFavorite) {
      _favoriteController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _sparkleController.dispose();
    _favoriteController.dispose();
    _bubbleNudgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final inCompletedTab = widget.inCompletedTab;
    final priorityColor = _priorityColor(task.priority);
    final dueDate = task.dueDate;
    final overdue =
        dueDate != null && dueDate.isBefore(DateTime.now()) && !task.isDone;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => _deleteTask(context, task),
      background: _deleteBackground(),
      child: GestureDetector(
        onTap: inCompletedTab || task.isDone
            ? null
            : () => showTaskFormSheet(context, task: task),
        onTapDown: inCompletedTab || task.isDone
            ? null
            : (_) => _pressController.forward(),
        onTapUp: inCompletedTab || task.isDone
            ? null
            : (_) => _pressController.reverse(),
        onTapCancel: inCompletedTab || task.isDone
            ? null
            : _pressController.reverse,
        child: ScaleTransition(
          scale: inCompletedTab || task.isDone
              ? const AlwaysStoppedAnimation(1)
              : _pressScale,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: task.isDone ? 0.74 : 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xCC0D1715),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 8, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCheckbox(context, task),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AnimatedTitle(
                                title: task.title,
                                isDone: task.isDone,
                              ),
                              if (task.notes.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  task.notes,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: [
                                  _smallChip(
                                    task.category.label,
                                    task.category.color,
                                    icon: task.category.icon,
                                  ),
                                  _smallChip(task.priority.name, priorityColor),
                                  if (dueDate != null)
                                    _smallChip(
                                      task.hasTime
                                          ? '${_formatDate(dueDate)} ${_formatTime(dueDate)}'
                                          : _formatDate(dueDate),
                                      overdue ? _red : _muted,
                                      icon: Icons.calendar_today_rounded,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!inCompletedTab) _favoriteButton(context, task),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                tooltip: 'Delete task',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                onPressed: () => _confirmDelete(context, task),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: _muted,
                                  size: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteBackground() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 22),
    decoration: BoxDecoration(
      color: _red,
      borderRadius: BorderRadius.circular(28),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.delete_rounded, color: Color(0xFF301016)),
        SizedBox(width: 8),
        Text(
          'Delete',
          style: TextStyle(
            color: Color(0xFF301016),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _favoriteButton(BuildContext context, Task task) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        tooltip: task.isFavorite
            ? 'Remove from favourites'
            : 'Add to favourites',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        onPressed: () {
          HapticFeedback.lightImpact();
          context.read<TaskProvider>().toggleFavorite(task.id);
        },
        icon: AnimatedBuilder(
          animation: _favoriteController,
          builder: (context, child) {
            final t = _favoriteController.value;
            final scale = t < 0.45
                ? 1 + (0.35 * Curves.easeOutBack.transform(t / 0.45))
                : 1.35 -
                      (0.35 * Curves.easeOutBack.transform((t - 0.45) / 0.55));
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (task.isFavorite)
                  Icon(
                    Icons.favorite,
                    size: 21,
                    color: _pink.withValues(alpha: 0.2),
                  ),
                Transform.scale(
                  scale: scale,
                  child: Icon(
                    task.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: task.isFavorite ? _pink : _muted,
                    size: 19,
                  ),
                ),
                if (task.isFavorite && t > 0 && t < 1)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: _FavoriteBurstPainter(t)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF16221F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete this task?',
          style: TextStyle(color: Color(0xFFEEECFF)),
        ),
        content: const Text(
          'You can undo this action for a short time.',
          style: TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (!context.mounted || shouldDelete != true) return;
    await _deleteTask(context, task);
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final provider = context.read<TaskProvider>();
    await provider.deleteTask(task.id);
    showAppSnackBar(
      'Task deleted',
      icon: Icons.delete_outline_rounded,
      actionLabel: 'UNDO',
      onAction: () => provider.restoreTask(task),
    );
  }

  Widget _buildCheckbox(BuildContext context, Task task) {
    return SizedBox(
      width: 31,
      height: 31,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _bubbleNudgeController,
            builder: (context, child) {
              final progress = _bubbleNudgeController.value;
              final shake =
                  math.sin(progress * math.pi * 4) * (1 - progress) * 3;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (task.isDone) {
                  HapticFeedback.lightImpact();
                  _bubbleNudgeController.forward(from: 0);
                  showAppSnackBar(
                    'You have already completed this task',
                    icon: Icons.check_circle_rounded,
                  );
                  return;
                }
                HapticFeedback.mediumImpact();
                await context.read<TaskProvider>().completeTask(task.id);
                if (!context.mounted) return;
                showAppSnackBar(
                  'Task completed',
                  icon: Icons.check_circle_rounded,
                );
              },
              child: AnimatedScale(
                scale: task.isDone ? 1.12 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: task.isDone
                        ? const LinearGradient(
                            colors: [_green, Color(0xFF5EEAD4)],
                          )
                        : null,
                    color: task.isDone ? null : Colors.transparent,
                    border: Border.all(
                      color: task.isDone
                          ? _green
                          : Colors.white.withValues(alpha: 0.38),
                      width: 1.5,
                    ),
                  ),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(task.isDone),
                    tween: Tween<double>(begin: 0, end: task.isDone ? 1 : 0),
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    builder: (context, progress, _) => CustomPaint(
                      painter: _CheckPainter(progress, const Color(0xFF05231A)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (task.isDone)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, _) => CustomPaint(
                  size: const Size(46, 46),
                  painter: _SparklePainter(_sparkleController.value),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _smallChip(String label, Color color, {IconData? icon}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Color _priorityColor(Priority priority) => switch (priority) {
    Priority.low => _green,
    Priority.medium => _amber,
    Priority.high => _red,
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _AnimatedTitle extends StatelessWidget {
  const _AnimatedTitle({required this.title, required this.isDone});

  final String title;
  final bool isDone;

  @override
  Widget build(BuildContext context) => AnimatedDefaultTextStyle(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    style: TextStyle(
      color: isDone ? const Color(0xFFA9A6C8) : const Color(0xFFEEECFF),
      fontSize: 15,
      fontWeight: FontWeight.w700,
      decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
      decorationColor: isDone ? _green : Colors.transparent,
      decorationThickness: 1.5,
    ),
    child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
  );
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.68)
      ..lineTo(size.width * 0.76, size.height * 0.34);
    final metrics = path.computeMetrics().first;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(metrics.extractPath(0, metrics.length * progress), paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final paint = Paint()..color = _green.withValues(alpha: 1 - progress);
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 7; i++) {
      final angle = i * math.pi * 2 / 7;
      final distance = 9 + progress * 15;
      final point =
          center +
          Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      canvas.drawCircle(point, 2.2 * (1 - progress * 0.6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _FavoriteBurstPainter extends CustomPainter {
  const _FavoriteBurstPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _pink.withValues(alpha: 1 - progress);
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi * 2 / 6;
      final distance = 5 + progress * 12;
      final point =
          center +
          Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      canvas.drawCircle(point, 1.8 * (1 - progress * 0.6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FavoriteBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
