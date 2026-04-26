import 'dart:io';

import 'package:swamp_task_management_app/src/domain/document/entities/document.dart';

abstract class DocumentRepository {
  Future<Document> uploadDocument(File file, String type);

  Stream<Document> watchDocumentStatus(String id);

  Future<Document> getStatus(String id);
}
