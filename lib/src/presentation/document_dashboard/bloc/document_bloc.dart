import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swamp_task_management_app/src/domain/document/repositories/document_repositories.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_event.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository repository;

  DocumentBloc({required this.repository}) : super(DocumentState.initial()) {
    on<UploadDocumentEvent>(_onUpload);
    on<DocumentStatusUpdated>(_onStatusUpdated);
  }

  void _onUpload(UploadDocumentEvent event, Emitter<DocumentState> emit) async {
    final document = await repository.uploadDocument(event.file, event.type);
    emit(DocumentState(documents: [...state.documents, document]));

    repository.watchDocumentStatus(document.id).listen((updated) {
      add(DocumentStatusUpdated(updated));
    });
  }

  void _onStatusUpdated(
    DocumentStatusUpdated event,
    Emitter<DocumentState> emit,
  ) {
    final updatedDocs = state.documents.map((doc) {
      return doc.id == event.document.id ? event.document : doc;
    }).toList();

    emit(DocumentState(documents: updatedDocs));
  }
}
