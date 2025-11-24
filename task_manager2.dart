import 'package:task_manager/task.dart';

void runApp() {
  // Create a task without due date
  final task1 = Task(id: '1', title: 'Learn Dart Basics');

  // Create a task with due date
  final task2 = Task(
    id: '2',
    title: 'Build Flutter App',
    description: 'Create a todo app',
    dueDate: DateTime.now().add(Duration(days: 7)),
  );

  print(task1);
  print(task2);
  print('Task 1 overdue: ${task1.isOverdue()}');
  print('Task 2 overdue: ${task2.isOverdue()}');
}
