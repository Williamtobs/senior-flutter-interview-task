import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  final Task task;
  CreateTaskEvent(this.task);
}

class MoveTaskEvent extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;

  MoveTaskEvent(this.taskId, this.newStatus);
}
