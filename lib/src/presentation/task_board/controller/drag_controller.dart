import 'package:flutter/material.dart';
import '../../../domain/task/entities/task.dart';

class DragController extends ChangeNotifier {
  Task? draggingTask;
  Offset position = Offset.zero;
  TaskStatus? hoveringStatus;

  bool get isDragging => draggingTask != null;

  void startDrag(Task task, Offset startPosition) {
    draggingTask = task;
    position = startPosition;
    notifyListeners();
  }

  void updatePosition(Offset newPosition) {
    position = newPosition;
    notifyListeners();
  }

  void updateHover(TaskStatus? status) {
    if (hoveringStatus != status) {
      hoveringStatus = status;
      notifyListeners();
    }
  }

  void endDrag() {
    draggingTask = null;
    hoveringStatus = null;
    notifyListeners();
  }
}
