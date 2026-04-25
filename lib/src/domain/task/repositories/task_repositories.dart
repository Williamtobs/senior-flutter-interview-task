import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';

abstract class TaskRepository {
  List<Task> getTasks();
  void createTask(Task task);
  void updateTask(Task task);
  void deleteTask(String id);
}
