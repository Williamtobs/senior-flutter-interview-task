import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_state.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/controller/drag_controller.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/widgets/task_card.dart';

class TaskColumn extends StatefulWidget {
  final TaskStatus status;

  const TaskColumn({super.key, required this.status});

  @override
  State<TaskColumn> createState() => _TaskColumnState();
}

class _TaskColumnState extends State<TaskColumn> {
  final GlobalKey _key = GlobalKey();

  void _registerColumnBounds() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final position = box.localToGlobal(Offset.zero);
    final rect = position & box.size;
    context.read<DragController>().registerColumn(widget.status, rect);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _registerColumnBounds(),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerColumnBounds();
    });

    return AnimatedContainer(
      key: _key,
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _TaskList(status: widget.status),
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
  final List<GlobalKey> _itemKeys = [];

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

        // ensure keys match length
        _itemKeys
          ..clear()
          ..addAll(List.generate(tasks.length, (_) => GlobalKey()));

        return Consumer<DragController>(
          builder: (context, drag, _) {
            // 🔥 trigger auto scroll when dragging
            // if (drag.isDragging) {
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     if (mounted) _handleAutoScroll(drag);
            //   });
            // }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !drag.isDragging) return;
              if (drag.hoveringStatus != widget.status) return;

              for (int i = 0; i < _itemKeys.length; i++) {
                final context = _itemKeys[i].currentContext;
                if (context == null) continue;

                final box = context.findRenderObject() as RenderBox;
                final pos = box.localToGlobal(Offset.zero);
                final rect = pos & box.size;

                if (rect.contains(drag.position)) {
                  drag.updateTargetIndex(i);
                  return;
                }
              }

              // if below last item → insert at end
              drag.updateTargetIndex(tasks.length);
              _handleAutoScroll(drag);
            });

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];

                // final isBeingDragged = drag.draggingTask?.id == task.id;

                // return AnimatedOpacity(
                //   duration: const Duration(milliseconds: 200),
                //   opacity: isBeingDragged ? 0.0 : 1.0,
                //   child: TaskCard(task: task),
                // );
                return Column(
                  children: [
                    if (drag.targetIndex == index &&
                        drag.hoveringStatus == widget.status)
                      _DropIndicator(),

                    _buildTaskItem(task, drag, index),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTaskItem(Task task, DragController drag, int index) {
    final isDragging = drag.draggingTask?.id == task.id;

    return Container(
      key: _itemKeys[index],
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDragging ? 0.0 : 1.0,
        child: TaskCard(task: task, isDragging: isDragging),
      ),
    );
  }
}

class _DropIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
