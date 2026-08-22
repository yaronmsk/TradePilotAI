import 'package:flutter/material.dart';

import '../models/metric_explainability.dart';

class MetricExplainabilityContent extends StatelessWidget {
  const MetricExplainabilityContent({super.key, required this.explainability});

  final MetricExplainability explainability;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ExplainabilitySection(
          title: 'Semantic role',
          content: explainability.semanticRole.label,
        ),
        _ExplainabilitySection(
          title: 'What does this mean?',
          content: explainability.whatItIs,
        ),
        _ExplainabilitySection(
          title: 'How is it calculated?',
          content: explainability.calculation,
        ),
        _ExplainabilitySection(
          title: 'Why does it matter?',
          content: explainability.whyItMatters,
        ),
        if (explainability.supportiveInterpretation != null)
          _ExplainabilitySection(
            title: 'Supportive interpretation',
            content: explainability.supportiveInterpretation!,
          ),
        if (explainability.opposingInterpretation != null)
          _ExplainabilitySection(
            title: 'Opposing interpretation',
            content: explainability.opposingInterpretation!,
          ),
        if (explainability.neutralInterpretation != null)
          _ExplainabilitySection(
            title: 'Neutral interpretation',
            content: explainability.neutralInterpretation!,
          ),
        _ExplainabilitySection(
          title: 'How does it affect the recommendation?',
          content: explainability.recommendationImpact,
        ),
        if (explainability.boundedImpact != null)
          _ExplainabilitySection(
            title: 'Impact boundary',
            content: explainability.boundedImpact!,
          ),
        _ExplainabilitySection(
          title: 'Limitations',
          content: explainability.limitations,
          addBottomSpacing: false,
        ),
      ],
    );
  }
}

class _ExplainabilitySection extends StatelessWidget {
  const _ExplainabilitySection({
    required this.title,
    required this.content,
    this.addBottomSpacing = true,
  });

  final String title;
  final String content;
  final bool addBottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: addBottomSpacing ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(content),
        ],
      ),
    );
  }
}
