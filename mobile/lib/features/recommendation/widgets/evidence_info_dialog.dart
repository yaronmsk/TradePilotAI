import 'package:flutter/material.dart';

import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import 'metric_explainability_content.dart';

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
    final explainability = definition.explainability;

    return AlertDialog(
      title: Text(definition.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Evidence family: ${definition.family.label}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            if (explainability != null)
              MetricExplainabilityContent(explainability: explainability)
            else
              _LegacyEvidenceExplanation(definition: definition),
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

class _LegacyEvidenceExplanation extends StatelessWidget {
  const _LegacyEvidenceExplanation({required this.definition});

  final EvidenceDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
