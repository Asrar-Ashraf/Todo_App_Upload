import 'package:flutter/material.dart';

enum Priority { low, medium, high }

enum TaskCategory {
  home(
    'Home',
    Icons.home_rounded,
    Color(0xFF34D399),
    'Chores and family',
  ),
  office(
    'Office',
    Icons.work_rounded,
    Color(0xFF22D3EE),
    'Work and meetings',
  ),
  study(
    'Study',
    Icons.menu_book_rounded,
    Color(0xFFA78BFA),
    'Learning and exams',
  ),
  shopping(
    'Shopping',
    Icons.shopping_bag_rounded,
    Color(0xFFFBBF24),
    'Things to buy',
  ),
  health(
    'Health',
    Icons.favorite_rounded,
    Color(0xFFFB7185),
    'Fitness and care',
  ),
  other(
    'Other',
    Icons.auto_awesome_rounded,
    Color(0xFF94A3B8),
    'Anything else',
  );

  const TaskCategory(this.label, this.icon, this.color, this.hint);

  final String label;
  final IconData icon;
  final Color color;
  final String hint;
}

class Task {
  const Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.isDone = false,
    this.isFavorite = false,
    this.category = TaskCategory.other,
    this.hasTime = false,
    this.reminderMinutesBefore = 0,
    this.reminderEnabled = true,
    this.priority = Priority.medium,
    this.dueDate,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String notes;
  final bool isDone;
  final bool isFavorite;
  final TaskCategory category;
  final bool hasTime;
  final int reminderMinutesBefore;
  final bool reminderEnabled;
  final Priority priority;
  final DateTime? dueDate;
  final DateTime createdAt;

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    bool? isDone,
    bool? isFavorite,
    TaskCategory? category,
    bool? hasTime,
    int? reminderMinutesBefore,
    bool? reminderEnabled,
    Priority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isDone: isDone ?? this.isDone,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      hasTime: hasTime ?? this.hasTime,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'isDone': isDone,
    'isFavorite': isFavorite,
    'category': category.name,
    'hasTime': hasTime,
    'reminderMinutesBefore': reminderMinutesBefore,
    'reminderEnabled': reminderEnabled,
    'priority': priority.name,
    'dueDate': dueDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    final category = TaskCategory.values.firstWhere(
      (value) => value.name == json['category'],
      orElse: () => TaskCategory.other,
    );
    final priority = Priority.values.firstWhere(
      (value) => value.name == json['priority'],
      orElse: () => Priority.medium,
    );
    final rawDueDate = json['dueDate'];
    final dueDate = rawDueDate is String ? DateTime.tryParse(rawDueDate) : null;
    final rawCreatedAt = json['createdAt'];
    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      category: category,
      hasTime: json['hasTime'] as bool? ?? false,
      reminderMinutesBefore:
          json['reminderMinutesBefore'] as int? ?? 0,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      priority: priority,
      dueDate: dueDate,
      createdAt: rawCreatedAt is String
          ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
