import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

enum SortOption { dueDate, priority, newest }

class TaskProvider extends ChangeNotifier {
  TaskProvider({StorageService? storageService})
    : _storageService = storageService ?? StorageService();

  final StorageService _storageService;
  final List<Task> _tasks = [];
  SortOption _sortOption = SortOption.dueDate;

  SortOption get sortOption => _sortOption;
  List<Task> get allTasks => List.unmodifiable(_tasks);

  List<Task> get tasks {
    final sortedTasks = List<Task>.of(_tasks);
    sortedTasks.sort((first, second) {
      if (first.isDone != second.isDone) {
        return first.isDone ? 1 : -1;
      }
      switch (_sortOption) {
        case SortOption.dueDate:
          if (first.dueDate != null && second.dueDate != null) {
            final dueDateOrder = first.dueDate!.compareTo(second.dueDate!);
            if (dueDateOrder != 0) return dueDateOrder;
          } else if (first.dueDate != null) {
            return -1;
          } else if (second.dueDate != null) {
            return 1;
          }
          break;
        case SortOption.priority:
          final priorityOrder = _priorityRank(
            second.priority,
          ).compareTo(_priorityRank(first.priority));
          if (priorityOrder != 0) return priorityOrder;
          break;
        case SortOption.newest:
          final createdOrder = second.createdAt.compareTo(first.createdAt);
          if (createdOrder != 0) return createdOrder;
          break;
      }
      return first.createdAt.compareTo(second.createdAt);
    });
    return List.unmodifiable(sortedTasks);
  }

  int get completedCount => _tasks.where((task) => task.isDone).length;
  int get favoriteCount => _tasks.where((task) => task.isFavorite).length;
  int get totalCount => _tasks.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  Future<void> load() async {
    _tasks
      ..clear()
      ..addAll(await _storageService.loadTasks());
    final preferences = await SharedPreferences.getInstance();
    final savedSort = preferences.getString('taskflow_sort_option');
    _sortOption = SortOption.values.firstWhere(
      (option) => option.name == savedSort,
      orElse: () => SortOption.dueDate,
    );
    notifyListeners();
  }

  Future<void> setSortOption(SortOption option) async {
    if (_sortOption == option) return;
    _sortOption = option;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('taskflow_sort_option', option.name);
  }

  Future<void> addTask(
    String title, {
    String notes = '',
    Priority priority = Priority.medium,
    DateTime? dueDate,
    TaskCategory category = TaskCategory.other,
    bool hasTime = false,
    int reminderMinutesBefore = 0,
    bool reminderEnabled = true,
  }) async {
    final task = Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        notes: notes,
        category: category,
        hasTime: hasTime,
        reminderMinutesBefore: reminderMinutesBefore,
        reminderEnabled: reminderEnabled,
        priority: priority,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
    _tasks.add(task);
    await _saveAndNotify();
    await NotificationService.instance.scheduleForTask(task);
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return;
    final previous = _tasks[index];
    final task = updatedTask.copyWith(isFavorite: previous.isFavorite);
    _tasks[index] = task;
    await _saveAndNotify();
    if (task.isDone ||
        !task.reminderEnabled ||
        task.dueDate == null ||
        !task.hasTime) {
      await NotificationService.instance.cancelForTask(previous.id);
    } else {
      await NotificationService.instance.scheduleForTask(task);
    }
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    final removed = _tasks.removeAt(index);
    await _saveAndNotify();
    await NotificationService.instance.cancelForTask(removed.id);
  }

  Future<void> clearCompleted() async {
    final completed = _tasks.where((task) => task.isDone).toList();
    final previousLength = _tasks.length;
    _tasks.removeWhere((task) => task.isDone);
    if (_tasks.length == previousLength) return;
    await _saveAndNotify();
    for (final task in completed) {
      await NotificationService.instance.cancelForTask(task.id);
    }
  }

  Future<void> toggleDone(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    if (_tasks[index].isDone) return;
    _tasks[index] = _tasks[index].copyWith(isDone: true);
    await _saveAndNotify();
    await NotificationService.instance.cancelForTask(id);
  }

  Future<DateTime?> completeTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1 || _tasks[index].isDone) return null;
    final task = _tasks[index];
    _tasks[index] = task.copyWith(isDone: true);
    await _saveAndNotify();
    await NotificationService.instance.cancelForTask(id);
    return null;
  }

  Future<void> toggleFavorite(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      isFavorite: !_tasks[index].isFavorite,
    );
    await _saveAndNotify();
  }

  Future<void> restoreTask(Task task) async {
    _tasks.removeWhere((existing) => existing.id == task.id);
    _tasks.add(task);
    await _saveAndNotify();
    await NotificationService.instance.scheduleForTask(task);
  }

  Future<void> _saveAndNotify() async {
    notifyListeners();
    await _storageService.saveTasks(_tasks);
  }

  int _priorityRank(Priority priority) => switch (priority) {
    Priority.high => 3,
    Priority.medium => 2,
    Priority.low => 1,
  };

}
