import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskDueStep extends StatelessWidget {
  const TaskDueStep({
    required this.dueDate,
    required this.hasTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onHasTimeChanged,
    required this.reminderEnabled,
    required this.reminderMinutesBefore,
    required this.onReminderEnabledChanged,
    required this.onReminderMinutesChanged,
    required this.onFirstTimePicked,
    this.showHeading = true,
    super.key,
  });

  final DateTime? dueDate;
  final bool hasTime;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<DateTime> onTimeChanged;
  final ValueChanged<bool> onHasTimeChanged;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final ValueChanged<bool> onReminderEnabledChanged;
  final ValueChanged<int> onReminderMinutesChanged;
  final Future<void> Function() onFirstTimePicked;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final quickDates = [
      ('Today', _dateOnly(DateTime.now())),
      ('Tomorrow', _dateOnly(DateTime.now().add(const Duration(days: 1)))),
      ('This weekend', _nextSaturday()),
      ('Next week', _dateOnly(DateTime.now().add(const Duration(days: 7)))),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
          const Text(
            'When is it due?',
            style: TextStyle(
              color: Color(0xFFEEECFF),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 17),
        ],
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final (label, date) in quickDates)
              _quickChip(label, _sameDay(dueDate, date), () {
                HapticFeedback.selectionClick();
                onDateChanged(_withTime(date, dueDate, hasTime));
              }),
            _quickChip('No due date', dueDate == null, () {
              HapticFeedback.selectionClick();
              onDateChanged(null);
              onHasTimeChanged(false);
            }),
          ],
        ),
        const SizedBox(height: 16),
        _pickerRow(
          icon: Icons.calendar_month_rounded,
          label: 'Pick a date',
          value: dueDate == null ? null : _formatDate(dueDate!),
          onTap: () => _pickDate(context),
          onClear: dueDate == null ? null : () => onDateChanged(null),
        ),
        const SizedBox(height: 9),
        _pickerRow(
          icon: Icons.schedule_rounded,
          label: 'Add time',
          value: hasTime && dueDate != null ? _formatTime(dueDate!) : null,
          onTap: dueDate == null ? null : () => _pickTime(context),
          onClear: !hasTime || dueDate == null
              ? null
              : () {
                  onDateChanged(
                    DateTime(dueDate!.year, dueDate!.month, dueDate!.day),
                  );
                  onHasTimeChanged(false);
                },
          enabled: dueDate != null,
        ),
        const SizedBox(height: 18),
        const Text(
          'QUICK TIME',
          style: TextStyle(
            color: Color(0xFFA9A6C8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final (label, hour) in [
              ('Morning', 9),
              ('Afternoon', 14),
              ('Evening', 18),
              ('Night', 21),
            ])
              _quickChip(
                '$label ${_formatHour(hour)}',
                hasTime && dueDate?.hour == hour,
                () {
                  HapticFeedback.selectionClick();
                  final date = dueDate ?? DateTime.now();
                  _chooseTime(DateTime(date.year, date.month, date.day, hour));
                },
              ),
          ],
        ),
        if (hasTime && dueDate != null) ...[
          const SizedBox(height: 15),
          _reminderCard(),
          if (_reminderMomentHasPassed)
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 7),
              child: Text(
                'This time has already passed',
                style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11),
              ),
            ),
        ],
      ],
    );
  }

  bool get _reminderMomentHasPassed =>
      reminderEnabled &&
      dueDate != null &&
      dueDate!
          .subtract(Duration(minutes: reminderMinutesBefore))
          .isBefore(DateTime.now());

  Widget _reminderCard() {
    const options = [
      (0, 'At due time'),
      (10, '10 min before'),
      (60, '1 hour before'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1715),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF22D3EE),
                size: 18,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Remind me',
                  style: TextStyle(
                    color: Color(0xFFEEECFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: reminderEnabled,
                activeTrackColor: const Color(0xFF34D399),
                onChanged: onReminderEnabledChanged,
              ),
            ],
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: reminderEnabled ? 1 : 0.45,
            child: IgnorePointer(
              ignoring: !reminderEnabled,
              child: Wrap(
                spacing: 6,
                runSpacing: 5,
                children: [
                  for (final (minutes, label) in options)
                    _reminderChip(
                      label,
                      reminderMinutesBefore == minutes,
                      () {
                        HapticFeedback.selectionClick();
                        onReminderMinutesChanged(minutes);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF34D399).withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF34D399)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF34D399) : const Color(0xFFEEECFF),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _chooseTime(DateTime dateTime) async {
    if (reminderEnabled && !hasTime) await onFirstTimePicked();
    onTimeChanged(dateTime);
  }

  Widget _quickChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF05231A) : const Color(0xFFEEECFF),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: const Color(0xFF34D399),
      backgroundColor: Colors.white.withValues(alpha: 0.045),
      side: BorderSide(
        color: selected
            ? const Color(0xFF34D399)
            : Colors.white.withValues(alpha: 0.08),
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _pickerRow({
    required IconData icon,
    required String label,
    required String? value,
    required VoidCallback? onTap,
    required VoidCallback? onClear,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1715),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: enabled
                          ? const Color(0xFF34D399)
                          : const Color(0xFFA9A6C8).withValues(alpha: 0.45),
                      size: 19,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        value ?? label,
                        style: TextStyle(
                          color: enabled
                              ? (value == null
                                    ? const Color(0xFFA9A6C8)
                                    : const Color(0xFFEEECFF))
                              : const Color(0xFFA9A6C8).withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (value == null)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFA9A6C8),
                        size: 19,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              tooltip: 'Clear',
              onPressed: onClear,
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFFA9A6C8),
                size: 17,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final selected = await showDatePicker(
      context: context,
      initialDate: dueDate ?? today,
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: DateTime(today.year + 5, today.month, today.day),
      builder: (context, child) => _pickerTheme(child!),
    );
    if (!context.mounted || selected == null) return;
    onDateChanged(_withTime(selected, dueDate, hasTime));
  }

  Future<void> _pickTime(BuildContext context) async {
    final initial = dueDate == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay.fromDateTime(dueDate!);
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => _pickerTheme(child!),
    );
    if (!context.mounted || selected == null || dueDate == null) return;
    await _chooseTime(
      DateTime(
        dueDate!.year,
        dueDate!.month,
        dueDate!.day,
        selected.hour,
        selected.minute,
      ),
    );
  }

  Theme _pickerTheme(Widget child) => Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF34D399),
        onPrimary: Color(0xFF05231A),
        surface: Color(0xFF16221F),
        onSurface: Color(0xFFEEECFF),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF16221F)),
    ),
    child: child,
  );

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _nextSaturday() {
    final today = _dateOnly(DateTime.now());
    final days = (DateTime.saturday - today.weekday) % 7;
    return today.add(Duration(days: days));
  }

  static bool _sameDay(DateTime? first, DateTime second) =>
      first != null &&
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  static DateTime _withTime(DateTime date, DateTime? previous, bool hasTime) =>
      DateTime(
        date.year,
        date.month,
        date.day,
        hasTime ? previous?.hour ?? 0 : 0,
        hasTime ? previous?.minute ?? 0 : 0,
      );

  static String _formatDate(DateTime date) {
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

  static String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  static String _formatHour(int hour) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 ${hour < 12 ? 'AM' : 'PM'}';
  }
}
