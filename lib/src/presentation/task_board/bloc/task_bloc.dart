import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/domain/task/repositories/task_repositories.dart';
import 'package:swamp_task_management_app/src/domain/task/usecases/create_task.dart';
import 'package:swamp_task_management_app/src/domain/task/usecases/move_task.dart';

import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_event.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final CreateTask createTask;
  final MoveTask moveTask;
  final TaskRepository repository;

  TaskBloc({
    required this.createTask,
    required this.moveTask,
    required this.repository,
  }) : super(TaskState.initial()) {
    on<LoadTasks>(_onLoad);
    on<CreateTaskEvent>(_onCreate);
    on<MoveTaskEvent>(_onMove);
  }

  void _onLoad(LoadTasks event, Emitter<TaskState> emit) {
    final tasks = repository.getTasks();
    emit(_group(tasks));
  }

  void _onCreate(CreateTaskEvent event, Emitter<TaskState> emit) {
    createTask(event.task);
    add(LoadTasks());
  }

  void _onMove(MoveTaskEvent event, Emitter<TaskState> emit) {
    final tasks = repository.getTasks();
    final task = tasks.firstWhere((t) => t.id == event.taskId);

    final updated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      status: event.newStatus,
      priority: task.priority,
      dueDate: task.dueDate,
    );

    repository.updateTask(updated);
    add(LoadTasks());
  }

  TaskState _group(List<Task> tasks) {
    final map = {
      TaskStatus.todo: <Task>[],
      TaskStatus.inProgress: <Task>[],
      TaskStatus.done: <Task>[],
    };

    for (final t in tasks) {
      map[t.status]!.add(t);
    }

    return TaskState(groupedTasks: map);
  }
}
