import 'dart:io';
import 'dart:math';

import 'package:swamp_task_management_app/src/domain/document/entities/document.dart';
import 'package:swamp_task_management_app/src/domain/document/repositories/document_repositories.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final Map<String, Document> _store = {};

  @override
  Stream<Document> watchDocumentStatus(String id) async* {
    try {
      await for (final document in _mockWebSocket(id)) {
        yield document;
      }
    } catch (e) {
      print('WebSocket error: $e. Falling back to polling.');
      yield* _pollingFallback(id);
    }
  }

  @override
  Future<Document> uploadDocument(File file, String type) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final doc = Document(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: file.path.split('/').last,
      type: type,
      status: DocumentStatus.uploaded,
      progress: 0.0,
      uploadedAt: DateTime.now(),
    );

    _store[doc.id] = doc;

    return doc;
  }

  @override
  Future<Document> getStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final existing = _store[id];
    if (existing == null) {
      throw Exception('Document not found');
    }

    // simulate progression
    final nextProgress = (existing.progress + 0.25).clamp(0.0, 1.0);

    DocumentStatus status;

    if (nextProgress < 1.0) {
      status = DocumentStatus.processing;
    } else {
      // randomly reject or verify (realistic)
      final isRejected = DateTime.now().second % 5 == 0;

      status = isRejected ? DocumentStatus.rejected : DocumentStatus.verified;
    }

    final updated = existing.copyWith(
      progress: nextProgress,
      status: status,
      rejectionReason: status == DocumentStatus.rejected
          ? 'Blurry image'
          : null,
    );

    _store[id] = updated;

    return updated;
  }

  Stream<Document> _pollingFallback(String id) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));

      final doc = await getStatus(id);

      yield doc;

      if (doc.status == DocumentStatus.verified ||
          doc.status == DocumentStatus.rejected) {
        break;
      }
    }
  }

  Stream<Document> _mockWebSocket(String id) async* {
    final random = Random();

    final steps = [0.2, 0.5, 0.8, 1.0];

    for (final progress in steps) {
      await Future.delayed(Duration(milliseconds: 700 + random.nextInt(800)));

      final existing = _store[id];
      if (existing == null) throw Exception('Lost connection');

      // simulate occasional socket failure
      if (random.nextInt(10) == 0) {
        throw Exception('WebSocket disconnected');
      }

      DocumentStatus status;

      if (progress < 1.0) {
        status = DocumentStatus.processing;
      } else {
        final isRejected = random.nextBool();

        status = isRejected ? DocumentStatus.rejected : DocumentStatus.verified;
      }

      final updated = existing.copyWith(
        progress: progress,
        status: status,
        rejectionReason: status == DocumentStatus.rejected
            ? 'Invalid document'
            : null,
      );

      _store[id] = updated;

      yield updated;

      if (status == DocumentStatus.verified ||
          status == DocumentStatus.rejected) {
        break;
      }
    }
  }
}
