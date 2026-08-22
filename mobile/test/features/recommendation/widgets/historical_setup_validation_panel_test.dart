import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_setup_case.dart';
import 'package:mobile/features/recommendation/history/historical_setup_fingerprint.dart';
import 'package:mobile/features/recommendation/history/historical_setup_match.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/history/historical_validation_scoring_breakdown.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/widgets/historical_setup_validation_panel.dart';

void main() {
  HistoricalSetupValidation validation() {
    final fingerprint = HistoricalSetupFingerprint(
      strategy: StrategyType.trader,
      primaryTimeframe: '5m',
      stockBehaviorType: StockBehaviorType.volatile,
      volatilityRegime: VolatilityRegime.elevated,
      marketBackdrop: MarketBackdrop.supportive,
      relativeStrengthState: RelativeStrengthState.outperforming,
      familyDirectionScores: const {EvidenceFamily.trend: 70},
      familyStrengthScores: const {EvidenceFamily.trend: 80},
      familyImportanceWeights: const {EvidenceFamily.trend: 1},
    );

    final match = HistoricalSetupMatch(
      setupCase: HistoricalSetupCase(
        symbol: 'NVDA',
        occurredAt: DateTime.utc(2025, 5, 20),
        fingerprint: fingerprint,
        forwardReturnPercent: 1.4,
        maxFavorableExcursionPercent: 2,
        maxAdverseExcursionPercent: -0.6,
      ),
      similarity: 0.96,
      weight: 0.92,
    );

    return HistoricalSetupValidation(
      status: HistoricalValidationStatus.available,
      reliability: HistoricalValidationReliability.high,
      verdict: HistoricalValidationVerdict.supports,
      matchedCases: 40,
      effectiveSampleSize: 38,
      averageSimilarity: 0.96,
      alignedOutcomeRate: 0.63,
      controlAlignedOutcomeRate: 0.29,
      edgeVsControlPercentagePoints: 34,
      medianForwardReturnPercent: 1.1,
      medianDirectionalReturnPercent: 1.1,
      medianFavorableExcursionPercent: 1.9,
      medianAdverseExcursionPercent: -0.7,
      confidenceImpactPoints: 4.9,
      outcomeWindowLabel: 'Next 24 × 5m bars (~2 hours)',
      outcomeWindowShortLabel: '~2 hours',
      summary:
          'Similar historical setups show stronger follow-through than this stock usually showed under comparable surrounding conditions.',
      isSynthetic: true,
      sourceLabel: 'Development simulation',
      topMatches: [match],
      symbol: 'NVDA',
      stockProfileLabel: 'Volatile',
      comparisonCases: 72,
      scoringBreakdown: const HistoricalValidationScoringBreakdown(
        edgeVsControlWeight: 0.40,
        followThroughWeight: 0.20,
        outcomeMagnitudeWeight: 0.20,
        excursionQualityWeight: 0.20,
        edgeVsControlScore: 0.68,
        followThroughScore: 0.38,
        outcomeMagnitudeScore: 0.55,
        excursionQualityScore: 0.46,
        weightedOutcomeScore: 0.55,
        confidenceEligibleScore: 0.55,
        effectiveSampleReliability: 0.91,
        matchQualityReliability: 0.96,
        appliedReliability: 0.91,
      ),
    );
  }

  testWidgets(
    'explains setup follow-through and same-stock comparable baseline',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalSetupValidationPanel(validation: validation()),
            ),
          ),
        ),
      );

      expect(find.text('Historical Setup Check'), findsOneWidget);
      expect(find.text('Supports'), findsOneWidget);
      expect(
        find.text('Based on 40 similar cases • 96% match quality'),
        findsOneWidget,
      );
      expect(
        find.text('Similar historical setups: 63% follow-through'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'NVDA and other stocks with the same Volatile Stock Profile',
        ),
        findsOneWidget,
      );
      expect(
        find.text('NVDA under comparable conditions: 29% follow-through'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          "Across NVDA's historical data under the same Volatile Stock Profile",
        ),
        findsOneWidget,
      );
      expect(find.text('Historical Difference: +34% points'), findsOneWidget);
      expect(find.text('Confidence effect: +4.9 points'), findsOneWidget);

      await tester.tap(find.text('How was this calculated?'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Next 24 × 5m bars'), findsOneWidget);
      expect(find.text('NVDA comparison observations'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('Closest historical matches'), findsOneWidget);
      expect(find.textContaining('NVDA · 2025-05-20'), findsOneWidget);
      expect(find.text('Historical scoring weights'), findsOneWidget);
      expect(find.text('Difference vs stock baseline (40%)'), findsOneWidget);
      expect(find.text('Directional follow-through (20%)'), findsOneWidget);
      expect(find.text('Applied reliability'), findsOneWidget);
      expect(find.text('91%'), findsNWidgets(2));
      expect(find.textContaining('synthetic development data'), findsOneWidget);
    },
  );

  testWidgets(
    'info dialog explains strict profile matching and baseline logic',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HistoricalSetupValidationPanel(validation: validation()),
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('About Historical Setup Check'));
      await tester.pumpAndSettle();

      expect(find.text('About Historical Setup Check'), findsOneWidget);
      expect(find.text('Confidence / risk only'), findsOneWidget);
      expect(find.text('Supportive interpretation'), findsOneWidget);
      expect(find.text('Opposing interpretation'), findsOneWidget);
      expect(
        find.textContaining('above both 50% and the same-stock baseline'),
        findsOneWidget,
      );
      expect(find.textContaining('±8 points'), findsOneWidget);
      expect(
        find.textContaining('does not alter evidence confidence'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Historical similarity does not guarantee future performance',
        ),
        findsOneWidget,
      );
    },
  );
}
