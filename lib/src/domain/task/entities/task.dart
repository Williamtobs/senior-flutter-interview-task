import 'package:equatable/equatable.dart';

enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, medium, high }

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
  });

  @override
  List<Object?> get props => [id, title, status];
}
