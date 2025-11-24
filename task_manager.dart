import 'dart:io';
import 'dart:convert';
import 'task.dart';

// Manages collection of tasks
class TaskManager {
  // Private list of tasks - only accessible within class
  final List<Task> _tasks = [];

  // Private map for quick task lookup by ID
  final Map<String, Task> _taskMap = {};

  // Set of task IDs for uniqueness checking
  final Set<String> _taskIds = {};

  // Getter for all tasks - returns unmodifiable list
  List<Task> get allTasks => List.unmodifiable(_tasks);

  // Getter for pending tasks only
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  // Getter for completed tasks only
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  // Add a new task
  bool addTask(Task task) {
    // Check if task ID already exists
    if (_taskIds.contains(task.id)) {
      return false; // Task ID must be unique
    }

    _tasks.add(task);
    _taskMap[task.id] = task;
    _taskIds.add(task.id);
    return true;
  }

  // Find task by ID - returns null if not found
  Task? findTaskById(String id) {
    return _taskMap[id];
  }

  // Remove task by ID
  bool removeTask(String id) {
    final task = _taskMap[id];
    if (task == null) {
      return false;
    }

    _tasks.remove(task);
    _taskMap.remove(id);
    _taskIds.remove(id);
    return true;
  }

  // Edit existing task fields; null parameters are skipped
  bool editTask(
    String id, {
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    final task = _taskMap[id];
    if (task == null) return false;
    if (title != null) task.title = title;
    if (description != null) task.description = description;
    if (dueDate != null) task.dueDate = dueDate;
    if (isCompleted != null) task.isCompleted = isCompleted;
    return true;
  }

  // Search tasks by title (case-insensitive, substring match)
  List<Task> searchTasksByTitle(String query) {
    final q = query.toLowerCase();
    return _tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  // Get tasks due within specified days
  List<Task> getTasksDueWithin(int days) {
    final deadline = DateTime.now().add(Duration(days: days));
    return _tasks.where((task) {
      final due = task.dueDate;
      return due != null && due.isBefore(deadline) && !task.isCompleted;
    }).toList();
  }

  // Count tasks by status
  Map<String, int> getTaskStats() {
    return {
      'total': _tasks.length,
      'pending': pendingTasks.length,
      'completed': completedTasks.length,
      'overdue': _tasks.where((t) => t.isOverdue()).length,
    };
    //count tasks by due date
  }

  // Save tasks to a JSON file (overwrites if exists)
  Future<void> saveToFile(String path) async {
    final file = File(path);
    final list = _tasks.map((t) => t.toJson()).toList();
    await file.writeAsString(jsonEncode(list));
  }

  // Load tasks from a JSON file (replaces current tasks). Returns true if loaded.
  Future<bool> loadFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;
    final content = await file.readAsString();
    final decoded = jsonDecode(content) as List<dynamic>;

    _tasks.clear();
    _taskMap.clear();
    _taskIds.clear();

    for (final item in decoded) {
      final task = Task.fromJson(item as Map<String, dynamic>);
      _tasks.add(task);
      _taskMap[task.id] = task;
      _taskIds.add(task.id);
    }
    return true;
  }
}
