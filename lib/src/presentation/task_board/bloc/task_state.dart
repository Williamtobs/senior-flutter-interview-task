import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';

class TaskState {
  final Map<TaskStatus, List<Task>> groupedTasks;

  TaskState({required this.groupedTasks});

  factory TaskState.initial() => TaskState(
    groupedTasks: {
      TaskStatus.todo: [],
      TaskStatus.inProgress: [],
      TaskStatus.done: [],
    },
  );
}
