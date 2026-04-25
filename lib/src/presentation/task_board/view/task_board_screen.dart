import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:swamp_task_management_app/src/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_event.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/controller/drag_controller.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/widgets/task_board.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/widgets/task_card.dart';
import 'package:uuid/uuid.dart';

class TaskBoardScreen extends StatelessWidget {
  const TaskBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DragController()),
        BlocProvider(create: (_) => sl<TaskBloc>()..add(LoadTasks())),
      ],
      child: const _TaskBoardView(),
    );
  }
}

class _TaskBoardView extends StatelessWidget {
  const _TaskBoardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const TaskBoard(),

            // 🔥 Drag overlay
            Consumer<DragController>(
              builder: (_, drag, _) {
                if (!drag.isDragging) return const SizedBox();

                return Positioned(
                  left: drag.position.dx - 100,
                  top: drag.position.dy - 40,
                  child: IgnorePointer(
                    child: Transform.scale(
                      scale: 1.05,
                      child: Opacity(
                        opacity: 0.9,
                        child: TaskCard(
                          task: drag.draggingTask!,
                          isDragging: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final task = Task(
            id: const Uuid().v4(),
            title: 'New Task',
            description: 'Created just now',
            status: TaskStatus.todo,
            priority: TaskPriority.medium,
          );

          context.read<TaskBloc>().add(CreateTaskEvent(task));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
