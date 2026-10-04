import '../models/task.dart';

const Map<TaskCategory, List<String>> taskSuggestions = {
  TaskCategory.home: [
    'Clean the house',
    'Do laundry',
    'Cook dinner',
    'Pay utility bills',
    'Fix something',
  ],
  TaskCategory.office: [
    'Team meeting',
    'Send report',
    'Reply to emails',
    'Prepare presentation',
    'Client call',
  ],
  TaskCategory.study: [
    'Revise notes',
    'Finish assignment',
    'Prepare for exam',
    'Read a chapter',
    'Practice coding',
  ],
  TaskCategory.shopping: [
    'Buy groceries',
    'Buy medicines',
    'Order online',
    'Gift shopping',
    'Make shopping list',
  ],
  TaskCategory.health: [
    'Morning walk',
    'Workout',
    'Drink water',
    'Doctor appointment',
    'Take medicine',
  ],
  TaskCategory.other: [
    'Make a call',
    'Visit a relative',
    'Plan a trip',
    'Renew documents',
    'Book tickets',
  ],
};
