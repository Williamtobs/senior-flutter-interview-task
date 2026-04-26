import 'dart:io';

import 'package:swamp_task_management_app/src/domain/document/entities/document.dart';

abstract class DocumentEvent {}

class UploadDocumentEvent extends DocumentEvent {
  final File file;
  final String type;

  UploadDocumentEvent(this.file, this.type);
}

class DocumentStatusUpdated extends DocumentEvent {
  final Document document;

  DocumentStatusUpdated(this.document);
}
