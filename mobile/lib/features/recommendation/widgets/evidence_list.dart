import 'package:flutter/material.dart';

import '../models/evidence_result.dart';
import 'evidence_card.dart';

class EvidenceList extends StatelessWidget {
  const EvidenceList({required this.results, super.key});

  final List<EvidenceResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No evidence available.')),
        ),
      );
    }

    return Column(
      children: results
          .map((result) => EvidenceCard(result: result))
          .toList(growable: false),
    );
  }
}
