import 'package:flutter/material.dart';

import '../models/evidence_definition.dart';

class EvidenceInfoDialog extends StatelessWidget {
  const EvidenceInfoDialog({super.key, required this.definition});

  final EvidenceDefinition definition;

  static Future<void> show(
    BuildContext context, {
    required EvidenceDefinition definition,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => EvidenceInfoDialog(definition: definition),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(definition.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What is it?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(definition.description),
            const SizedBox(height: 16),
            const Text(
              'Why does it matter?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(definition.whyItMatters),
            const SizedBox(height: 16),
            const Text(
              'How is it calculated?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(definition.calculation),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
