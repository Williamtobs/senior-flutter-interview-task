import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/domain/task/repositories/task_repositories.dart';

class TaskRepositoryImpl implements TaskRepository {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Collect waste from Zone A',
      description: 'Morning pickup',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
    ),
    Task(
      id: '2',
      title: 'Sort recyclables',
      description: 'Plastic and metals',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
    ),
    Task(
      id: '3',
      title: 'Dispatch truck',
      description: 'Send to landfill',
      status: TaskStatus.done,
      priority: TaskPriority.low,
    ),
  ];

  @override
  List<Task> getTasks() => List.unmodifiable(_tasks);

  @override
  void createTask(Task task) {
    _tasks.add(task);
  }

  @override
  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
  }
}
