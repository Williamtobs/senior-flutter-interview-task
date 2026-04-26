import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_bloc.dart';
import 'package:swamp_task_management_app/src/presentation/document_dashboard/bloc/document_event.dart';

class UploadButton extends StatelessWidget {
  const UploadButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        // mock file
        final file = File('sample_id_card.png');

        context.read<DocumentBloc>().add(UploadDocumentEvent(file, 'ID_CARD'));
      },
      child: const Icon(Icons.upload),
    );
  }
}
