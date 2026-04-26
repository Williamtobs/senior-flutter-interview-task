import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No documents yet.\nUpload one to get started.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
