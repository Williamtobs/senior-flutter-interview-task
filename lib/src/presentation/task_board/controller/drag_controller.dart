import 'package:flutter/material.dart';
import '../../../domain/task/entities/task.dart';

class DragController extends ChangeNotifier {
  Task? draggingTask;
  Offset position = Offset.zero;
  TaskStatus? hoveringStatus;

  final Map<TaskStatus, Rect> columnBounds = {};

  int? targetIndex; // 🔥 NEW

  bool get isDragging => draggingTask != null;

  void startDrag(Task task, Offset startPosition) {
    draggingTask = task;
    position = startPosition;
    targetIndex = null;
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

  void updateTargetIndex(int? index) {
    if (targetIndex != index) {
      targetIndex = index;
      notifyListeners();
    }
  }

  void endDrag() {
    draggingTask = null;
    hoveringStatus = null;
    targetIndex = null;
    notifyListeners();
  }

  void registerColumn(TaskStatus status, Rect rect) {
    columnBounds[status] = rect;
  }

  TaskStatus? getHoverAtPosition(Offset position) {
    for (final entry in columnBounds.entries) {
      if (entry.value.contains(position)) {
        return entry.key;
      }
    }
    return null;
  }
}
