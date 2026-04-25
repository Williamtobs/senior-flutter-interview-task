import 'package:flutter/material.dart';
import 'package:swamp_task_management_app/src/domain/task/entities/task.dart';
import 'package:swamp_task_management_app/src/presentation/task_board/widgets/task_column.dart';

class TaskBoard extends StatelessWidget {
  const TaskBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: const [
          Expanded(
            child: _LabeledTaskColumn(
              title: 'To Do',
              subtitle: 'Tasks waiting to start',
              status: TaskStatus.todo,
            ),
          ),
          Expanded(
            child: _LabeledTaskColumn(
              title: 'In Progress',
              subtitle: 'Tasks currently being worked on',
              status: TaskStatus.inProgress,
            ),
          ),
          Expanded(
            child: _LabeledTaskColumn(
              title: 'Done',
              subtitle: 'Tasks completed successfully',
              status: TaskStatus.done,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledTaskColumn extends StatelessWidget {
  final String title;
  final String subtitle;
  final TaskStatus status;

  const _LabeledTaskColumn({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: TaskColumn(status: status)),
        ],
      ),
    );
  }
}
