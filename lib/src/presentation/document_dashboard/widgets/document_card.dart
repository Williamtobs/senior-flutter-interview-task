import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swamp_task_management_app/src/domain/document/entities/document.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_event.dart';

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor().withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(document: document),
          const SizedBox(height: 10),

          if (document.status == DocumentStatus.processing ||
              document.status == DocumentStatus.uploaded)
            _ProgressBar(progress: document.progress),

          if (document.status == DocumentStatus.rejected)
            _RejectionView(document: document),
        ],
      ),
    );
  }

  Color _statusColor() {
    switch (document.status) {
      case DocumentStatus.pending:
        return Colors.grey;
      case DocumentStatus.uploaded:
      case DocumentStatus.processing:
        return Colors.blue;
      case DocumentStatus.verified:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
    }
  }
}

class _Header extends StatelessWidget {
  final Document document;

  const _Header({required this.document});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.insert_drive_file),
        const SizedBox(width: 8),

        Expanded(
          child: Text(
            document.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        _StatusBadge(status: document.status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _color() {
    switch (status) {
      case DocumentStatus.pending:
        return Colors.grey;
      case DocumentStatus.uploaded:
      case DocumentStatus.processing:
        return Colors.blue;
      case DocumentStatus.verified:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 4),
        Text('${(progress * 100).toInt()}%'),
      ],
    );
  }
}

class _RejectionView extends StatelessWidget {
  final Document document;

  const _RejectionView({required this.document});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          document.rejectionReason ?? 'Rejected',
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () {
            final file = File(document.name);

            context.read<DocumentBloc>().add(
              UploadDocumentEvent(file, document.type),
            );
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
