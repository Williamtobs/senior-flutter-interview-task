import 'package:swamp_task_management_app/src/domain/task/repositories/task_repositories.dart';

class DeleteTask {
  final TaskRepository repository;

  DeleteTask(this.repository);

  void call(String id) {
    repository.deleteTask(id);
  }
}
