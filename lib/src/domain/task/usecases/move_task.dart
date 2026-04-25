import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/domain/task/repositories/task_repositories.dart';

class MoveTask {
  final TaskRepository repository;

  MoveTask(this.repository);

  void call(String taskId, TaskStatus newStatus) {
    final tasks = repository.getTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        status: newStatus,
        dueDate: task.dueDate,
        priority: task.priority,
      );
      repository.updateTask(updatedTask);
    }
  }
}
