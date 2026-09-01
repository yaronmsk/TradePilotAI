import 'package:flutter/material.dart';

import '../models/evidence_family.dart';
import '../models/evidence_family_summary.dart';
import '../models/evidence_result.dart';
import 'evidence_card.dart';

class EvidenceList extends StatelessWidget {
  const EvidenceList({
    required this.results,
    this.familySummaries = const [],
    super.key,
  });

  final List<EvidenceResult> results;
  final List<EvidenceFamilySummary> familySummaries;

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

    final grouped = <EvidenceFamily, List<EvidenceResult>>{};

    for (final result in results) {
      grouped
          .putIfAbsent(result.definition.family, () => <EvidenceResult>[])
          .add(result);
    }

    return Column(
      children: grouped.entries
          .map(
            (entry) => _EvidenceFamilyGroup(
              family: entry.key,
              results: entry.value,
              summary: _summaryFor(entry.key),
            ),
          )
          .toList(growable: false),
    );
  }

  EvidenceFamilySummary? _summaryFor(EvidenceFamily family) {
    for (final summary in familySummaries) {
      if (summary.family == family) {
        return summary;
      }
    }
    return null;
  }
}

class _EvidenceFamilyGroup extends StatelessWidget {
  const _EvidenceFamilyGroup({
    required this.family,
    required this.results,
    required this.summary,
  });

  final EvidenceFamily family;
  final List<EvidenceResult> results;
  final EvidenceFamilySummary? summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        key: PageStorageKey<String>('evidence-family-${family.name}'),
        title: Text(
          '${_friendlyFamilyLabel(family)} Evidence',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_subtitle()),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: results
            .map(
              (result) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: EvidenceCard(result: result),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  String _subtitle() {
    final countText =
        '${results.length} signal${results.length == 1 ? '' : 's'}';
    final familySummary = summary;

    if (familySummary == null) {
      return countText;
    }

    return '$countText · ${_directionLabel(familySummary.direction)}';
  }

  String _friendlyFamilyLabel(EvidenceFamily family) {
    switch (family) {
      case EvidenceFamily.generic:
        return 'Other';
      case EvidenceFamily.trend:
        return 'Trend';
      case EvidenceFamily.momentum:
        return 'Momentum';
      case EvidenceFamily.participation:
        return 'Volume Activity';
      case EvidenceFamily.priceStructure:
        return 'Price Structure';
      case EvidenceFamily.volatility:
        return 'Volatility';
      case EvidenceFamily.marketContext:
        return 'Market Context';
      case EvidenceFamily.fundamentals:
        return 'Fundamentals';
      case EvidenceFamily.sentiment:
        return 'Sentiment';
      case EvidenceFamily.growth:
        return 'Growth';
      case EvidenceFamily.profitabilityQuality:
        return 'Profitability & Quality';
      case EvidenceFamily.financialStrength:
        return 'Financial Strength';
      case EvidenceFamily.valuation:
        return 'Valuation';
      case EvidenceFamily.revisions:
        return 'Revisions';
      case EvidenceFamily.competitiveDurability:
        return 'Competitive Durability';
      case EvidenceFamily.capitalAllocation:
        return 'Capital Allocation';
      case EvidenceFamily.ownershipPositioning:
        return 'Ownership & Positioning';
    }
  }

  String _directionLabel(EvidenceDirection direction) {
    switch (direction) {
      case EvidenceDirection.bullish:
        return 'Bullish';
      case EvidenceDirection.bearish:
        return 'Bearish';
      case EvidenceDirection.neutral:
        return 'Neutral';
      case EvidenceDirection.unknown:
        return 'Unknown';
    }
  }
}
