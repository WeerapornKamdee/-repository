import 'dart:io';
import 'package:test/test.dart';
import 'package:task_manager/task_manager.dart';
import 'package:task_manager/task.dart';

void main() {
  group('TaskManager', () {
    late TaskManager manager;

    setUp(() {
      manager = TaskManager();
    });

    test('add and prevent duplicate', () {
      final t1 = Task(id: '1', title: 'A');
      expect(manager.addTask(t1), isTrue);
      expect(manager.allTasks.length, 1);

      final tDup = Task(id: '1', title: 'Duplicate');
      expect(manager.addTask(tDup), isFalse);
      expect(manager.allTasks.length, 1);
    });

    test('edit task', () {
      final t1 = Task(
        id: '1',
        title: 'Old',
        description: 'desc',
        isCompleted: false,
      );
      manager.addTask(t1);

      final ok = manager.editTask(
        '1',
        title: 'New',
        description: 'newdesc',
        isCompleted: true,
      );
      expect(ok, isTrue);

      final res = manager.findTaskById('1')!;
      expect(res.title, 'New');
      expect(res.description, 'newdesc');
      expect(res.isCompleted, isTrue);
    });

    test('search by title', () {
      manager.addTask(Task(id: '1', title: 'Learn Dart'));
      manager.addTask(Task(id: '2', title: 'Dart Testing'));
      manager.addTask(Task(id: '3', title: 'Other'));

      final results = manager.searchTasksByTitle('dart');
      expect(results.length, 2);
      expect(results.map((t) => t.id).toSet(), containsAll({'1', '2'}));
    });

    test('remove task', () {
      manager.addTask(Task(id: '1', title: 'To Remove'));
      expect(manager.removeTask('1'), isTrue);
      expect(manager.removeTask('1'), isFalse);
      expect(manager.allTasks, isEmpty);
    });

    test('save and load tasks', () async {
      manager.addTask(Task(id: '1', title: 'One'));
      manager.addTask(Task(id: '2', title: 'Two', description: 'desc'));

      final tmp = Directory.systemTemp.createTempSync('task_manager_test');
      final file = File('${tmp.path}${Platform.pathSeparator}tasks.json');

      await manager.saveToFile(file.path);

      final m2 = TaskManager();
      final loaded = await m2.loadFromFile(file.path);
      expect(loaded, isTrue);
      expect(m2.allTasks.length, 2);
      expect(m2.findTaskById('1')?.title, 'One');

      // cleanup
      if (await file.exists()) await file.delete();
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });
  });
}
