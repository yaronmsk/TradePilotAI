import 'package:flutter/material.dart';

import '../models/evidence_result.dart';
import 'evidence_info_dialog.dart';

class EvidenceCard extends StatelessWidget {
  const EvidenceCard({required this.result, super.key});

  final EvidenceResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _iconForDirection(result.direction),
                  color: _colorForDirection(result.direction),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.providerName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tooltip(
                  message: 'About this indicator',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      EvidenceInfoDialog.show(
                        context,
                        definition: result.definition,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.info_outline, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRow('Direction', result.direction.name.toUpperCase()),
            _buildRow('Strength', result.strength.name),
            _buildRow('Current Value', result.currentValue),
            _buildRow('Baseline', result.baselineValue),
            _buildRow('Relative', result.relativeValue),
            _buildRow(
              'Reliability',
              '${(result.reliability * 100).toStringAsFixed(0)}%',
            ),
            _buildRow('Weight', result.effectiveWeight.toStringAsFixed(2)),
            const SizedBox(height: 12),
            Text(
              result.explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _iconForDirection(EvidenceDirection direction) {
    switch (direction) {
      case EvidenceDirection.bullish:
        return Icons.trending_up;

      case EvidenceDirection.bearish:
        return Icons.trending_down;

      case EvidenceDirection.neutral:
        return Icons.remove;

      case EvidenceDirection.unknown:
        return Icons.help_outline;
    }
  }

  Color _colorForDirection(EvidenceDirection direction) {
    switch (direction) {
      case EvidenceDirection.bullish:
        return Colors.green;

      case EvidenceDirection.bearish:
        return Colors.red;

      case EvidenceDirection.neutral:
        return Colors.orange;

      case EvidenceDirection.unknown:
        return Colors.grey;
    }
  }
}
