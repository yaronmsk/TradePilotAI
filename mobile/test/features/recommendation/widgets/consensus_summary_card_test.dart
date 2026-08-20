import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_contribution.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_family_summary.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';
import 'package:mobile/features/recommendation/models/strategy_recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/widgets/consensus_summary_card.dart';

void main() {
  StrategyRecommendation buildRecommendation() {
    const trendProvider = EvidenceContribution(
      providerName: 'Candle Trend',
      family: EvidenceFamily.trend,
      direction: EvidenceDirection.bullish,
      directionImpactPoints: 38,
      directionShareWithinFamily: 1,
      confidenceContributionPoints: 34,
      confidenceShare: 0.41,
    );

    const momentumProvider = EvidenceContribution(
      providerName: 'RSI',
      family: EvidenceFamily.momentum,
      direction: EvidenceDirection.bullish,
      directionImpactPoints: 26,
      directionShareWithinFamily: 1,
      confidenceContributionPoints: 28,
      confidenceShare: 0.34,
    );

    const volumeProvider = EvidenceContribution(
      providerName: 'Relative Volume',
      family: EvidenceFamily.participation,
      direction: EvidenceDirection.bearish,
      directionImpactPoints: -12,
      directionShareWithinFamily: 1,
      confidenceContributionPoints: 20,
      confidenceShare: 0.25,
    );

    final consensus = ScoringResult(
      score: 82,
      coverage: 1,
      bullishWeight: 1.8,
      bearishWeight: 0.4,
      neutralWeight: 0.2,
      warnings: const [],
      directionScore: 64,
      familyCoverage: 1,
      agreement: 0.82,
      conflict: 0.36,
      bullishSupportPercent: 82,
      bearishSupportPercent: 18,
      independentFamilyCount: 3,
      baseEvidenceStrength: 88,
      confidenceModifiers: const [
        ConfidenceModifierImpact(
          label: 'Provider coverage',
          factor: 1,
          before: 88,
          after: 88,
        ),
        ConfidenceModifierImpact(
          label: 'Evidence-group coverage',
          factor: 1,
          before: 88,
          after: 88,
        ),
        ConfidenceModifierImpact(
          label: 'Signal alignment',
          factor: 0.95,
          before: 88,
          after: 83.6,
        ),
        ConfidenceModifierImpact(
          label: 'Data reliability',
          factor: 82 / 83.6,
          before: 83.6,
          after: 82,
        ),
      ],
      providerContributions: const [
        trendProvider,
        momentumProvider,
        volumeProvider,
      ],
      familyContributions: const [
        EvidenceFamilyContribution(
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          directionImpactPoints: 38,
          directionShare: 0.50,
          confidenceContributionPoints: 34,
          confidenceShare: 0.41,
          providers: [trendProvider],
        ),
        EvidenceFamilyContribution(
          family: EvidenceFamily.momentum,
          direction: EvidenceDirection.bullish,
          directionImpactPoints: 26,
          directionShare: 0.34,
          confidenceContributionPoints: 28,
          confidenceShare: 0.34,
          providers: [momentumProvider],
        ),
        EvidenceFamilyContribution(
          family: EvidenceFamily.participation,
          direction: EvidenceDirection.bearish,
          directionImpactPoints: -12,
          directionShare: 0.16,
          confidenceContributionPoints: 20,
          confidenceShare: 0.25,
          providers: [volumeProvider],
        ),
      ],
      familySummaries: const [
        EvidenceFamilySummary(
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          directionScore: 82,
          strengthScore: 82,
          effectiveWeight: 1,
          reliability: 0.90,
          agreement: 1,
          evidenceCount: 1,
        ),
        EvidenceFamilySummary(
          family: EvidenceFamily.momentum,
          direction: EvidenceDirection.bullish,
          directionScore: 68,
          strengthScore: 68,
          effectiveWeight: 0.8,
          reliability: 0.84,
          agreement: 1,
          evidenceCount: 1,
        ),
        EvidenceFamilySummary(
          family: EvidenceFamily.participation,
          direction: EvidenceDirection.bearish,
          directionScore: -42,
          strengthScore: 42,
          effectiveWeight: 0.6,
          reliability: 0.78,
          agreement: 1,
          evidenceCount: 1,
        ),
      ],
    );

    return StrategyRecommendation(
      strategy: StrategyType.trader,
      recommendation: Recommendation(
        type: RecommendationType.buy,
        evidenceScore: consensus.confidence,
        oneLineExplanation: 'Bullish evidence has the stronger consensus.',
        timeframe: '5m',
        candleCount: 48,
        analysisTime: DateTime(2026, 8, 16, 12),
        evidenceReport: EvidenceReport.fromResults(
          results: const [],
          expectedProviderCount: 0,
        ),
        consensus: consensus,
      ),
    );
  }

  testWidgets('shows simplified user-facing insight metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ConsensusSummaryCard(
              strategyRecommendation: buildRecommendation(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Trader Recommendation Insight'), findsOneWidget);
    expect(find.text('Signal Strength'), findsOneWidget);
    expect(find.text('Confidence'), findsOneWidget);
    expect(find.text('Signal Alignment'), findsOneWidget);
    expect(find.text('Strong Bullish'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Strongly Aligned'), findsOneWidget);
    expect(find.text('Why this confidence?'), findsOneWidget);
    expect(find.text('Evidence Contribution'), findsOneWidget);
    expect(find.text('Supports 50%'), findsOneWidget);
    expect(find.text('Opposes 16%'), findsOneWidget);
  });

  testWidgets('shows exact provider attribution when a group is expanded', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ConsensusSummaryCard(
              strategyRecommendation: buildRecommendation(),
            ),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Trend'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trend'));
    await tester.pumpAndSettle();

    expect(find.text('Candle Trend'), findsOneWidget);
    expect(find.textContaining('Direction: +38.0 pts'), findsOneWidget);
    expect(
      find.textContaining('41% of evidence-derived confidence'),
      findsOneWidget,
    );
  });

  testWidgets('explains confidence calculation and attribution semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ConsensusSummaryCard(
              strategyRecommendation: buildRecommendation(),
            ),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.byTooltip('About Evidence Contribution'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('About Evidence Contribution'));
    await tester.pumpAndSettle();

    expect(find.textContaining('groups correlated indicators'), findsOneWidget);
    expect(
      find.textContaining('not a guaranteed probability of profit'),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Confidence calculation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confidence calculation'));
    await tester.pumpAndSettle();

    expect(find.text('Evidence-strength baseline'), findsOneWidget);
    expect(find.text('Signal alignment'), findsOneWidget);
    expect(find.text('Final confidence'), findsOneWidget);
  });

  testWidgets('keeps technical metrics behind explainability controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ConsensusSummaryCard(
              strategyRecommendation: buildRecommendation(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('About Confidence'));
    await tester.pumpAndSettle();

    expect(find.text('Confidence'), findsWidgets);
    expect(
      find.textContaining('not a guaranteed probability of profit'),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('How was this calculated?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How was this calculated?'));
    await tester.pumpAndSettle();

    expect(find.text('Bullish evidence'), findsOneWidget);
    expect(find.text('Bearish evidence'), findsOneWidget);
    expect(find.text('Evidence-group coverage'), findsOneWidget);
    expect(find.text('Average reliability'), findsOneWidget);
    expect(find.text('Internal agreement'), findsOneWidget);
    expect(find.text('Conflict level'), findsOneWidget);
  });
}
