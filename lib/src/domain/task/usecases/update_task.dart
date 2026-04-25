import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/domain/task/repositories/task_repositories.dart';

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  void call(Task task) {
    repository.updateTask(task);
  }
}
