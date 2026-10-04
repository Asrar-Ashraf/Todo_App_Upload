import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../providers/task_provider.dart';
import '../utils/app_snackbar.dart';
import 'wizard/step_category.dart';
import 'wizard/step_details.dart';
import 'wizard/step_due.dart';
import 'wizard/step_priority.dart';
import 'wizard/step_review.dart';
import 'wizard/wizard_progress.dart';

const _surface = Color(0xFF0D1715);
const _text = Color(0xFFEEECFF);
const _muted = Color(0xFFA9A6C8);
const _green = Color(0xFF34D399);
const _cyan = Color(0xFF22D3EE);

Future<void> showTaskFormSheet(BuildContext context, {Task? task}) {
  if (task != null && task.isDone) return Future<void>.value();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: _surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => _TaskFormSheet(task: task),
  );
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({this.task});

  final Task? task;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.task?.title ?? '',
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.task?.notes ?? '');
  late final PageController _pageController = PageController();
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _shakeAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 8, end: -5), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

  late TaskCategory _category = widget.task?.category ?? TaskCategory.other;
  late Priority _priority = widget.task?.priority ?? Priority.medium;
  late DateTime? _dueDate = widget.task?.dueDate;
  late bool _hasTime = widget.task?.hasTime ?? false;
  late int _reminderMinutesBefore = widget.task?.reminderMinutesBefore ?? 0;
  late bool _reminderEnabled = widget.task?.reminderEnabled ?? true;
  int _step = 0;
  bool _showTitleError = false;
  bool _saving = false;
  bool _permissionPrompted = false;

  bool get _isEditing => widget.task != null;

  bool get _hasChanges {
    final original = widget.task;
    if (original == null) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _category != TaskCategory.other ||
          _priority != Priority.medium ||
          _dueDate != null ||
          _hasTime ||
          !_reminderEnabled ||
          _reminderMinutesBefore != 0;
    }
    return _titleController.text != original.title ||
        _descriptionController.text != original.notes ||
        _category != original.category ||
        _priority != original.priority ||
        _dueDate != original.dueDate ||
        _hasTime != original.hasTime ||
        _reminderMinutesBefore != original.reminderMinutesBefore ||
        _reminderEnabled != original.reminderEnabled;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF16221F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Discard this task?', style: TextStyle(color: _text)),
        content: const Text(
          'Your changes will not be saved.',
          style: TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
    if (!mounted) return false;
    return discard ?? false;
  }

  Future<void> _requestClose() async {
    if (!await _confirmDiscard() || !mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _goToStep(int nextStep) async {
    if (nextStep < 0 || nextStep > 4 || nextStep == _step) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    setState(() => _step = nextStep);
    await _pageController.animateToPage(
      nextStep,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _selectCategory(TaskCategory category) async {
    setState(() => _category = category);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted || _category != category || _step != 0) return;
    await _goToStep(1);
  }

  Future<void> _next() async {
    if (_step == 1 && _titleController.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
      _shakeController.forward(from: 0);
      return;
    }
    if (_step < 4) {
      await _goToStep(_step + 1);
      return;
    }
    await _save();
  }

  Future<void> _save({bool addAnother = false}) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _step = 1;
        _showTitleError = true;
      });
      await _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    final provider = context.read<TaskProvider>();
    final original = widget.task;
    if (original == null) {
      await provider.addTask(
        title,
        notes: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
        hasTime: _hasTime,
        reminderMinutesBefore: _reminderMinutesBefore,
        reminderEnabled: _reminderEnabled,
      );
    } else {
      await provider.updateTask(
        original.copyWith(
          title: title,
          notes: _descriptionController.text.trim(),
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          hasTime: _hasTime,
          reminderMinutesBefore: _reminderMinutesBefore,
          reminderEnabled: _reminderEnabled,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (addAnother) {
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _category = TaskCategory.other;
        _priority = Priority.medium;
        _dueDate = null;
        _hasTime = false;
        _reminderMinutesBefore = 0;
        _reminderEnabled = true;
        _step = 0;
        _showTitleError = false;
      });
      await _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      if (!mounted) return;
      showAppSnackBar('Task added', icon: Icons.check_circle_rounded);
      return;
    }
    Navigator.of(context).pop();
    showAppSnackBar(
      original == null ? 'Task added' : 'Task updated',
      icon: Icons.check_circle_rounded,
    );
  }

  void _setDueDate(DateTime? value) {
    setState(() {
      _dueDate = value;
      if (value == null) _hasTime = false;
    });
  }

  void _setDueTime(DateTime value) {
    setState(() {
      _dueDate = value;
      _hasTime = true;
    });
  }

  Future<void> _requestReminderPermissionOnFirstTime() async {
    if (_permissionPrompted) return;
    _permissionPrompted = true;
    final notificationsAllowed = await NotificationService.instance
        .areNotificationsAllowed();
    if (!mounted) return;
    if (notificationsAllowed) {
      await NotificationService.instance.requestPermission();
      return;
    }
    final shouldAllow = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF16221F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Allow notifications?',
          style: TextStyle(color: _text),
        ),
        content: const Text(
          'We need permission to remind you at the right time',
          style: TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not now', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Allow', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
    if (!mounted || shouldAllow != true) return;
    final allowed = await NotificationService.instance.requestPermission();
    if (!mounted || allowed) return;
    showAppSnackBar(
      'Notifications are off. Enable them in phone Settings to get reminders.',
      icon: Icons.notifications_off_rounded,
    );
  }

  void _setReminderEnabled(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _reminderEnabled = value);
    if (value && _hasTime && !_permissionPrompted) {
      unawaited(_requestReminderPermissionOnFirstTime());
    }
  }

  void _setReminderMinutes(int value) {
    setState(() => _reminderMinutesBefore = value);
  }

  Widget _categoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in TaskCategory.values) ...[
            if (category != TaskCategory.values.first) const SizedBox(width: 7),
            ChoiceChip(
              selected: _category == category,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                setState(() => _category = category);
              },
              avatar: Icon(category.icon, color: category.color, size: 16),
              label: Text(category.label),
              selectedColor: category.color.withValues(alpha: 0.17),
              backgroundColor: Colors.white.withValues(alpha: 0.04),
              side: BorderSide(
                color: _category == category
                    ? category.color
                    : Colors.white.withValues(alpha: 0.08),
              ),
              labelStyle: TextStyle(
                color: _category == category ? category.color : _text,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }

  Widget _editSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        color: _text,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _buildEditBody() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _editSectionTitle('Task type'),
          _categoryChips(),
          const SizedBox(height: 22),
          _editSectionTitle('Details'),
          TaskDetailsStep(
            titleController: _titleController,
            descriptionController: _descriptionController,
            category: _category,
            onChangeCategory: () {},
            onTitleChanged: (_) {
              if (_showTitleError) setState(() => _showTitleError = false);
            },
            titleError: _showTitleError,
            shakeAnimation: _shakeAnimation,
            showCategoryChange: false,
            showHeading: false,
          ),
          const SizedBox(height: 22),
          _editSectionTitle('Priority'),
          TaskPriorityStep(
            priority: _priority,
            onSelected: (value) => setState(() => _priority = value),
            compact: true,
            showHeading: false,
          ),
          const SizedBox(height: 22),
          _editSectionTitle('Due date and time'),
          TaskDueStep(
            dueDate: _dueDate,
            hasTime: _hasTime,
            onDateChanged: _setDueDate,
            onTimeChanged: _setDueTime,
            onHasTimeChanged: (value) => setState(() => _hasTime = value),
            reminderEnabled: _reminderEnabled,
            reminderMinutesBefore: _reminderMinutesBefore,
            onReminderEnabledChanged: _setReminderEnabled,
            onReminderMinutesChanged: _setReminderMinutes,
            onFirstTimePicked: _requestReminderPermissionOnFirstTime,
            showHeading: false,
          ),
        ],
      ),
    );
  }

  Widget _buildWizardPage(int index) {
    final Widget content = switch (index) {
      0 => TaskCategoryStep(
        selectedCategory: _category,
        onSelected: _selectCategory,
      ),
      1 => TaskDetailsStep(
        titleController: _titleController,
        descriptionController: _descriptionController,
        category: _category,
        onChangeCategory: () => _goToStep(0),
        onTitleChanged: (_) {
          if (_showTitleError) setState(() => _showTitleError = false);
        },
        titleError: _showTitleError,
        shakeAnimation: _shakeAnimation,
      ),
      2 => TaskPriorityStep(
        priority: _priority,
        onSelected: (value) => setState(() => _priority = value),
      ),
      3 => TaskDueStep(
        dueDate: _dueDate,
        hasTime: _hasTime,
        onDateChanged: _setDueDate,
        onTimeChanged: _setDueTime,
        onHasTimeChanged: (value) => setState(() => _hasTime = value),
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
        onReminderEnabledChanged: _setReminderEnabled,
        onReminderMinutesChanged: _setReminderMinutes,
        onFirstTimePicked: _requestReminderPermissionOnFirstTime,
      ),
      _ => TaskReviewStep(
        category: _category,
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _priority,
        dueDate: _dueDate,
        hasTime: _hasTime,
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
        onEditStep: _goToStep,
        onSaveAndAddAnother: () => _save(addAnother: true),
      ),
    };
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: content,
    );
  }

  Widget _buildFooter() {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: _gradientButton(
          label: 'Save Changes',
          onPressed: _saving ? null : () => _save(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: _saving ? null : () => _goToStep(_step - 1),
              style: TextButton.styleFrom(
                foregroundColor: _muted,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 15,
                ),
              ),
              child: const Text('Back'),
            )
          else
            const SizedBox(width: 58),
          const SizedBox(width: 10),
          Expanded(
            child: _gradientButton(
              label: _step == 4 ? 'Add Task' : 'Next',
              onPressed: _saving ? null : _next,
              icon: _step == 4
                  ? Icons.check_rounded
                  : Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: onPressed == null
                ? [
                    _green.withValues(alpha: 0.45),
                    _cyan.withValues(alpha: 0.45),
                  ]
                : const [_green, _cyan],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            foregroundColor: const Color(0xFF05231A),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight =
        (MediaQuery.sizeOf(context).height * 0.94 - keyboardInset)
            .clamp(260.0, MediaQuery.sizeOf(context).height)
            .toDouble();
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _requestClose();
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SizedBox(
          height: availableHeight,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isEditing ? 'Edit Task' : 'New Task',
                            style: const TextStyle(
                              color: _text,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _requestClose,
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_rounded, color: _muted),
                        ),
                      ],
                    ),
                    if (!_isEditing) ...[
                      const SizedBox(height: 3),
                      WizardProgress(currentStep: _step + 1),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _isEditing
                    ? _buildEditBody()
                    : PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            _buildWizardPage(index),
                      ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
