import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_family_summary.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/widgets/evidence_list.dart';

void main() {
  EvidenceResult evidence(String name, EvidenceFamily family) {
    return EvidenceResult(
      providerName: name,
      definition: EvidenceDefinition(
        family: family,
        name: name,
        description: 'Description',
        whyItMatters: 'Why',
        calculation: 'Calculation',
      ),
      status: EvidenceStatus.available,
      direction: EvidenceDirection.bullish,
      strength: EvidenceStrength.strong,
      score: 80,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 0.9,
      currentValue: '1',
      baselineValue: '1',
      relativeValue: '0',
      explanation: 'Explanation',
    );
  }

  testWidgets('groups technical signals by evidence family', (tester) async {
    final results = [
      evidence('Candle Trend', EvidenceFamily.trend),
      evidence('EMA Structure', EvidenceFamily.trend),
      evidence('VWAP Position', EvidenceFamily.priceStructure),
    ];

    const summaries = [
      EvidenceFamilySummary(
        family: EvidenceFamily.trend,
        direction: EvidenceDirection.bullish,
        directionScore: 80,
        strengthScore: 80,
        effectiveWeight: 1,
        reliability: 0.9,
        agreement: 1,
        evidenceCount: 2,
      ),
      EvidenceFamilySummary(
        family: EvidenceFamily.priceStructure,
        direction: EvidenceDirection.bullish,
        directionScore: 70,
        strengthScore: 70,
        effectiveWeight: 0.8,
        reliability: 0.8,
        agreement: 1,
        evidenceCount: 1,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EvidenceList(results: results, familySummaries: summaries),
          ),
        ),
      ),
    );

    expect(find.text('Trend Evidence'), findsOneWidget);
    expect(find.text('2 signals · Bullish'), findsOneWidget);
    expect(find.text('Price Structure Evidence'), findsOneWidget);
    expect(find.text('1 signal · Bullish'), findsOneWidget);

    expect(find.text('Candle Trend'), findsNothing);

    await tester.tap(find.text('Trend Evidence'));
    await tester.pumpAndSettle();

    expect(find.text('Candle Trend'), findsOneWidget);
    expect(find.text('EMA Structure'), findsOneWidget);
  });
}
