import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'taskflow_tasks';

  Future<List<Task>> loadTasks() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encodedTasks = preferences.getString(_tasksKey);
      if (encodedTasks == null) return [];

      final decodedTasks = jsonDecode(encodedTasks);
      if (decodedTasks is! List) return [];

      return decodedTasks
          .map((item) => Task.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _tasksKey,
        jsonEncode(tasks.map((task) => task.toJson()).toList()),
      );
    } catch (_) {
      rethrow;
    }
  }
}
