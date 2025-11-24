// Priority task with priority level
import 'package:task_manager/task.dart';

class PriorityTask extends Task {
  // Priority levels: 1 (highest) to 3 (lowest)
  final int priority;

  PriorityTask({
    required super.id,
    required super.title,
    super.description,
    super.dueDate,
    super.isCompleted,
    this.priority = 2, // Default medium priority
  }) : assert(
         priority >= 1 && priority <= 3,
         'Priority must be between 1 and 3',
       );

  // Get priority label
  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return '${super.toString()} [Priority: $priorityLabel]';
  }
}

// Recurring task that repeats periodically
class RecurringTask extends Task {
  // Recurrence interval in days
  final int intervalDays;

  // Last completion date
  DateTime? lastCompleted;

  RecurringTask({
    required super.id,
    required super.title,
    super.description,
    super.dueDate,
    super.isCompleted,
    required this.intervalDays,
    this.lastCompleted,
  }) : assert(intervalDays > 0, 'Interval must be positive');

  // Calculate next due date
  DateTime? getNextDueDate() {
    final last = lastCompleted ?? dueDate;
    if (last == null) return null;
    return last.add(Duration(days: intervalDays));
  }

  @override
  void complete() {
    super.complete();
    lastCompleted = DateTime.now();
    // Reset for next occurrence
    isCompleted = false;
    dueDate = getNextDueDate();
  }

  @override
  String toString() {
    return '${super.toString()} [Repeats every $intervalDays days]';
  }
}
