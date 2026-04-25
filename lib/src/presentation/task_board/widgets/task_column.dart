import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_event.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_state.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/controller/drag_controller.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/widgets/task_card.dart';

class TaskColumn extends StatelessWidget {
  final TaskStatus status;

  const TaskColumn({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAccept: (_) => true,
      onAccept: (task) {
        context.read<TaskBloc>().add(MoveTaskEvent(task.id, status));
        context.read<DragController>().endDrag();
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _TaskList(status: status),
        );
      },
    );
  }
}

class _TaskList extends StatefulWidget {
  final TaskStatus status;

  const _TaskList({required this.status});

  @override
  State<_TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<_TaskList> {
  final ScrollController _scrollController = ScrollController();

  void _handleAutoScroll(DragController drag) {
    final position = drag.position.dy;
    const threshold = 120;
    const scrollSpeed = 12;

    final screenHeight = MediaQuery.of(context).size.height;

    if (position < threshold) {
      final newOffset = (_scrollController.offset - scrollSpeed).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(newOffset);
    } else if (position > screenHeight - threshold) {
      final newOffset = (_scrollController.offset + scrollSpeed).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(newOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      buildWhen: (prev, curr) =>
          prev.groupedTasks[widget.status] != curr.groupedTasks[widget.status],
      builder: (context, state) {
        final tasks = state.groupedTasks[widget.status] ?? [];

        return Consumer<DragController>(
          builder: (context, drag, _) {
            // 🔥 trigger auto scroll when dragging
            if (drag.isDragging) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _handleAutoScroll(drag);
              });
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];

                final isBeingDragged = drag.draggingTask?.id == task.id;

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isBeingDragged ? 0.0 : 1.0,
                  child: TaskCard(task: task),
                );
              },
            );
          },
        );
      },
    );
  }
}
