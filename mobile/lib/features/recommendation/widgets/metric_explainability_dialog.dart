import 'package:flutter/material.dart';

import '../models/metric_explainability.dart';
import 'metric_explainability_content.dart';

class MetricExplainabilityDialog extends StatelessWidget {
  const MetricExplainabilityDialog({
    super.key,
    required this.title,
    required this.explainability,
  });

  final String title;
  final MetricExplainability explainability;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required MetricExplainability explainability,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => MetricExplainabilityDialog(
        title: title,
        explainability: explainability,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('About $title'),
      content: SingleChildScrollView(
        child: MetricExplainabilityContent(explainability: explainability),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
