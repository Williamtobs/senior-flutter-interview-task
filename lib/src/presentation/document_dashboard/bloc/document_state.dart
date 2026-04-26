import 'package:swamp_task_management_app/src/domain/document/entities/document.dart';

class DocumentState {
  final List<Document> documents;

  const DocumentState({required this.documents});

  factory DocumentState.initial() => const DocumentState(documents: []);
}
