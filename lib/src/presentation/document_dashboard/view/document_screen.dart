import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swamp_task_management_app/src/core/di/injection.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_state.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/widgets/document_card.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/widgets/empty_state.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/widgets/upload_button.dart';

class DocumentDashboardPage extends StatelessWidget {
  const DocumentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DocumentBloc>(),
      child: const _DocumentDashboardView(),
    );
  }
}

class _DocumentDashboardView extends StatelessWidget {
  const _DocumentDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Verification')),
      floatingActionButton: const UploadButton(),
      body: const _DocumentList(),
    );
  }
}

class _DocumentList extends StatelessWidget {
  const _DocumentList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state.documents.isEmpty) {
          return const EmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.documents.length,
          itemBuilder: (_, index) {
            final doc = state.documents[index];
            return DocumentCard(document: doc);
          },
        );
      },
    );
  }
}
