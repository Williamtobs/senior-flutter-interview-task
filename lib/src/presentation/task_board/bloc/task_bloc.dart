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
    final currentTasks = List<Task>.from(repository.getTasks());

    final taskIndex = currentTasks.indexWhere((t) => t.id == event.taskId);

    if (taskIndex == -1) return;

    final task = currentTasks.removeAt(taskIndex); // ✅ remove FIRST

    final updated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      status: event.newStatus,
      priority: task.priority,
      dueDate: task.dueDate,
    );

    // 🔥 get only target column tasks AFTER removal
    final targetTasks = currentTasks
        .where((t) => t.status == event.newStatus)
        .toList();

    int insertIndex = event.newIndex ?? targetTasks.length;

    insertIndex = insertIndex.clamp(0, targetTasks.length);

    // 🔥 find global insert position
    final globalInsertIndex = currentTasks.indexWhere(
      (t) => t.status == event.newStatus,
    );

    if (globalInsertIndex == -1) {
      // no items in that column → just add
      currentTasks.add(updated);
    } else {
      currentTasks.insert(globalInsertIndex + insertIndex, updated);
    }

    repository.replaceAll(currentTasks);

    emit(_group(currentTasks)); // ✅ no need for LoadTasks()
  }

  TaskState _group(List<Task> tasks) {
    final map = {
      TaskStatus.todo: <Task>[],
      TaskStatus.inProgress: <Task>[],
      TaskStatus.done: <Task>[],
    };

    for (final task in tasks) {
      map[task.status]!.add(task);
    }

    return TaskState(groupedTasks: map);
  }
}
