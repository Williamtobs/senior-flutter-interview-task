import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/bloc/task_event.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/controller/drag_controller.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isDragging;

  const TaskCard({super.key, required this.task, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    final drag = context.read<DragController>();

    return GestureDetector(
      onLongPressStart: (details) {
        HapticFeedback.mediumImpact();
        drag.startDrag(task, details.globalPosition);
      },
      onLongPressMoveUpdate: (details) {
        drag.updatePosition(details.globalPosition);

        for (final entry in drag.columnBounds.entries) {
          if (entry.value.contains(details.globalPosition)) {
            drag.updateHover(entry.key);
            return;
          }
        }

        drag.updateHover(null);
      },
      onLongPressEnd: (details) {
        final drag = context.read<DragController>();
        drag.updatePosition(details.globalPosition);

        final hover = drag.getHoverAtPosition(details.globalPosition);

        if (hover != null && drag.draggingTask != null) {
          context.read<TaskBloc>().add(
            MoveTaskEvent(
              drag.draggingTask!.id,
              hover,
              newIndex: drag.targetIndex,
            ),
          );
        }

        drag.endDrag();
      },
      child: _cardBody(),
    );
  }

  Widget _cardBody() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDragging
            ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(task.description, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _priorityColor(task.priority),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.priority.name.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}
