import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation_explainability.dart';
import 'package:mobile/features/recommendation/history/historical_validation_strategy_policy.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';
import 'package:mobile/features/recommendation/models/analysis_context_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/analysis_context_metric.dart';
import 'package:mobile/features/recommendation/models/stock_behavior_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/event_risk_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/stock_dna_strategy_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_kind.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_evidence_policy.dart';

void main() {
  const coreSwingKinds = <EvidenceKind>[
    EvidenceKind.candleTrend,
    EvidenceKind.rsi,
    EvidenceKind.emaStructure,
    EvidenceKind.macdMomentum,
    EvidenceKind.multiTimeframeTrend,
  ];

  const batch4Kinds = <EvidenceKind>[
    EvidenceKind.relativeVolume,
    EvidenceKind.volumeConfirmation,
    EvidenceKind.supportResistance,
    EvidenceKind.priceExtension,
  ];

  group('Swing evidence readiness invariants', () {
    test('Batch 3 core evidence remains ready as later batches advance', () {
      final swing = StrategyAnalysisPolicyCatalog.swing;

      expect(
        swing.implementationReadyEvidenceKinds.toSet().containsAll(
          coreSwingKinds,
        ),
        isTrue,
      );

      expect(swing.isRecommendationActive, isTrue);
    });

    test('core evidence preserves intended family de-duplication', () {
      final swing = StrategyAnalysisPolicyCatalog.swing;

      const expectedFamilies = <EvidenceKind, EvidenceFamily>{
        EvidenceKind.candleTrend: EvidenceFamily.trend,
        EvidenceKind.emaStructure: EvidenceFamily.trend,
        EvidenceKind.multiTimeframeTrend: EvidenceFamily.trend,
        EvidenceKind.rsi: EvidenceFamily.momentum,
        EvidenceKind.macdMomentum: EvidenceFamily.momentum,
      };

      for (final entry in expectedFamilies.entries) {
        final policy = swing.policyFor(entry.key);

        expect(
          policy,
          isNotNull,
          reason: '${entry.key} must have a Swing policy.',
        );

        expect(
          policy!.family,
          entry.value,
          reason:
              '${entry.key} must remain in ${entry.value} '
              'for family-level de-duplication.',
        );
      }
    });

    test('all Batch 3 capabilities may affect direction and confidence', () {
      final swing = StrategyAnalysisPolicyCatalog.swing;

      for (final kind in coreSwingKinds) {
        final policy = swing.policyFor(kind);

        expect(policy, isNotNull);
        expect(
          policy!.implementationReady,
          isTrue,
          reason: '$kind must be explicitly Swing-ready.',
        );
        expect(
          policy.affectsDirection,
          isTrue,
          reason: '$kind must support directional evaluation.',
        );
        expect(
          policy.affectsConfidence,
          isTrue,
          reason: '$kind participates in evidence-derived confidence.',
        );
      }
    });

    test('core directional explainability is complete and two-sided', () {
      for (final kind in coreSwingKinds) {
        final explanation = EvidenceExplainabilityCatalog.forKind(kind);

        expect(
          explanation,
          isNotNull,
          reason: '$kind requires an explainability path.',
        );

        expect(
          explanation!.isComplete,
          isTrue,
          reason: '$kind explainability must be complete.',
        );

        expect(
          explanation.allowsDirectionalInfluence,
          isTrue,
          reason: '$kind is directional/evaluative.',
        );

        expect(
          explanation.supportiveInterpretation,
          isNotNull,
          reason: '$kind requires supportive interpretation.',
        );

        expect(
          explanation.opposingInterpretation,
          isNotNull,
          reason: '$kind requires opposing interpretation.',
        );
      }
    });

    test('Batch 4 calibrated capabilities remain implementation-ready', () {
      final swing = StrategyAnalysisPolicyCatalog.swing;

      expect(
        swing.implementationReadyEvidenceKinds.toSet().containsAll(batch4Kinds),
        isTrue,
      );

      for (final kind in batch4Kinds) {
        expect(
          swing.policyFor(kind)?.implementationReady,
          isTrue,
          reason: '$kind must remain Swing implementation-ready.',
        );
      }

      expect(swing.isRecommendationActive, isTrue);
    });

    test('all eligible Swing evidence is calibrated after Batch 5', () {
      final swing = StrategyAnalysisPolicyCatalog.swing;

      expect(
        swing.implementationReadyEvidenceKinds.toSet(),
        swing.eligibleEvidenceKinds.toSet(),
      );

      expect(swing.isRecommendationActive, isTrue);
    });

    test('Relative Volume is ready but remains data-quality conditional', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.relativeVolume,
      );

      expect(policy, isNotNull);

      expect(policy!.family, EvidenceFamily.participation);

      expect(
        policy.applicability,
        StrategyEvidenceApplicability.conditionalOnDataQuality,
      );

      expect(policy.implementationReady, isTrue);
      expect(policy.canUseCurrentImplementation, isTrue);
      expect(policy.dataQualityRequirement, isNotEmpty);
    });

    test(
      'Volume Confirmation is ready and shares the Participation family',
      () {
        final swing = StrategyAnalysisPolicyCatalog.swing;

        final relativeVolume = swing.policyFor(EvidenceKind.relativeVolume);

        final volumeConfirmation = swing.policyFor(
          EvidenceKind.volumeConfirmation,
        );

        expect(relativeVolume, isNotNull);
        expect(volumeConfirmation, isNotNull);

        expect(relativeVolume!.family, EvidenceFamily.participation);

        expect(volumeConfirmation!.family, EvidenceFamily.participation);

        expect(volumeConfirmation.implementationReady, isTrue);
        expect(volumeConfirmation.affectsDirection, isTrue);
        expect(volumeConfirmation.affectsConfidence, isTrue);

        final explanation = EvidenceExplainabilityCatalog.forKind(
          EvidenceKind.volumeConfirmation,
        );

        expect(explanation, isNotNull);
        expect(explanation!.isComplete, isTrue);
        expect(explanation.allowsDirectionalInfluence, isTrue);
        expect(explanation.supportiveInterpretation, isNotNull);
        expect(explanation.opposingInterpretation, isNotNull);
      },
    );

    test('Support & Resistance is ready with structure and risk semantics', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.supportResistance,
      );

      expect(policy, isNotNull);
      expect(policy!.implementationReady, isTrue);
      expect(policy.family, EvidenceFamily.priceStructure);
      expect(policy.affectsDirection, isTrue);
      expect(policy.affectsConfidence, isTrue);
      expect(policy.affectsRiskOrEntryQuality, isTrue);

      final explanation = EvidenceExplainabilityCatalog.forKind(
        EvidenceKind.supportResistance,
      );

      expect(explanation, isNotNull);
      expect(explanation!.isComplete, isTrue);
      expect(explanation.allowsDirectionalInfluence, isTrue);
      expect(explanation.neutralInterpretation, contains('Proximity'));
    });

    test('Price Extension is ready but cannot influence Swing direction', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.priceExtension,
      );

      expect(policy, isNotNull);
      expect(policy!.implementationReady, isTrue);
      expect(policy.family, EvidenceFamily.volatility);

      // This is the authoritative Swing-specific rule.
      expect(policy.affectsDirection, isFalse);
      expect(policy.affectsConfidence, isTrue);
      expect(policy.affectsRiskOrEntryQuality, isTrue);

      final explanation = EvidenceExplainabilityCatalog.forKind(
        EvidenceKind.priceExtension,
      );

      expect(explanation, isNotNull);
      expect(explanation!.isComplete, isTrue);

      // The explainability catalog is currently global across strategies.
      // Trader retains directional Price Extension behavior, so the global
      // evidence definition remains directional/evaluative.
      expect(explanation.allowsDirectionalInfluence, isTrue);

      expect(explanation.boundedImpact, isNotNull);
      expect(
        explanation.boundedImpact,
        contains('Swing directional impact is exactly zero'),
      );
    });

    test(
      'Market Context and Breadth are both ready inside one capped family',
      () {
        final swing = StrategyAnalysisPolicyCatalog.swing;

        final context = swing.policyFor(EvidenceKind.marketContext);

        final breadth = swing.policyFor(EvidenceKind.marketBreadth);

        expect(context, isNotNull);
        expect(breadth, isNotNull);

        expect(context!.implementationReady, isTrue);
        expect(breadth!.implementationReady, isTrue);

        expect(context.family, EvidenceFamily.marketContext);

        expect(breadth.family, EvidenceFamily.marketContext);

        expect(context.affectsDirection, isTrue);
        expect(breadth.affectsDirection, isTrue);

        expect(context.affectsConfidence, isTrue);
        expect(breadth.affectsConfidence, isTrue);

        final breadthExplanation = EvidenceExplainabilityCatalog.forKind(
          EvidenceKind.marketBreadth,
        );

        expect(breadthExplanation, isNotNull);
        expect(breadthExplanation!.isComplete, isTrue);

        expect(breadthExplanation.allowsDirectionalInfluence, isTrue);

        expect(
          breadthExplanation.recommendationImpact,
          contains('without becoming an independent second market vote'),
        );

        expect(swing.isRecommendationActive, isTrue);
      },
    );

    test(
      'Batch 5 preserves evidence context and confidence-only boundaries',
      () {
        final swing = StrategyAnalysisPolicyCatalog.swing;

        final marketContext = swing.policyFor(EvidenceKind.marketContext);
        final marketBreadth = swing.policyFor(EvidenceKind.marketBreadth);
        final news = swing.policyFor(EvidenceKind.newsSentiment);

        expect(marketContext, isNotNull);
        expect(marketBreadth, isNotNull);
        expect(news, isNotNull);

        expect(marketContext!.implementationReady, isTrue);
        expect(marketBreadth!.implementationReady, isTrue);
        expect(news!.implementationReady, isTrue);

        expect(marketContext.family, EvidenceFamily.marketContext);
        expect(marketBreadth.family, EvidenceFamily.marketContext);
        expect(news.family, EvidenceFamily.sentiment);

        expect(marketContext.affectsDirection, isTrue);
        expect(marketBreadth.affectsDirection, isTrue);
        expect(news.affectsDirection, isTrue);

        const stockDna = StockDnaStrategyPolicy.swing;

        expect(stockDna.requiresHistoricalBaseline, isTrue);
        expect(stockDna.minimumDynamicWeight, 0.75);
        expect(stockDna.maximumDynamicWeight, 1.20);

        for (final metric in StockBehaviorMetric.values) {
          final explanation = StockBehaviorExplainabilityCatalog.forMetric(
            metric,
          );

          expect(
            explanation.allowsDirectionalInfluence,
            isFalse,
            reason:
                '$metric must remain contextual and cannot '
                'manufacture BUY/SELL direction.',
          );
        }

        const eventRisk = EventRiskStrategyPolicy.swing;

        expect(eventRisk.maximumRelevantEarningsHours, 336);
        expect(eventRisk.maximumRelevantMacroHours, 168);
        expect(EventRiskStrategyPolicy.maximumPenaltyPoints, 12);

        final eventExplanation = AnalysisContextExplainabilityCatalog.forMetric(
          AnalysisContextMetric.eventRisk,
          strategy: StrategyType.swing,
        );

        expect(eventExplanation.allowsDirectionalInfluence, isFalse);
        expect(
          eventExplanation.boundedImpact,
          contains('-12 confidence points'),
        );
        expect(
          eventExplanation.recommendationImpact,
          contains('never adds confidence'),
        );

        expect(swing.isRecommendationActive, isTrue);
      },
    );

    test(
      'Batch 6 historical validation remains Swing-specific and confidence-only',
      () {
        const fourHour = HistoricalValidationStrategyPolicy.swingFourHour;
        const daily = HistoricalValidationStrategyPolicy.swingDaily;

        expect(fourHour.isStrategyCalibrated, isTrue);
        expect(daily.isStrategyCalibrated, isTrue);

        expect(fourHour.primaryTimeframe, '4h');
        expect(daily.primaryTimeframe, '1d');

        expect(fourHour.minimumMatchedCases, 10);
        expect(daily.minimumMatchedCases, 10);

        expect(fourHour.effectiveSampleFloor, 10);
        expect(daily.effectiveSampleFloor, 10);

        expect(fourHour.effectiveSampleFull, 32);
        expect(daily.effectiveSampleFull, 32);

        expect(fourHour.matchSimilarityFloor, 0.60);
        expect(daily.matchSimilarityFloor, 0.60);

        expect(fourHour.balancedExpectedMovePercent, 3.3);
        expect(daily.balancedExpectedMovePercent, 4.0);

        expect(HistoricalSetupValidation.maximumConfidenceImpactPoints, 8);

        const explanation = HistoricalSetupValidationExplainability.definition;

        expect(explanation.semanticRole, MetricSemanticRole.confidenceRiskOnly);

        expect(explanation.allowsDirectionalInfluence, isFalse);

        expect(
          explanation.recommendationImpact,
          contains('final confidence only'),
        );

        expect(explanation.boundedImpact, contains('±8 points'));

        expect(
          StrategyAnalysisPolicyCatalog.swing.isRecommendationActive,
          isTrue,
        );
      },
    );

    test('Batch 7 keeps Swing recommendation policy strategy-specific', () {
      const trader = RecommendationStrategyPolicy.trader;
      const swing = RecommendationStrategyPolicy.swing;

      expect(
        StrategyAnalysisPolicyCatalog.swing.isRecommendationActive,
        isTrue,
      );

      expect(
        swing.minimumProviderCoverage,
        greaterThan(trader.minimumProviderCoverage),
      );

      expect(
        swing.actionDirectionThreshold,
        greaterThan(trader.actionDirectionThreshold),
      );

      expect(
        swing.strongDirectionThreshold,
        greaterThan(trader.strongDirectionThreshold),
      );

      expect(
        swing.minimumActionConfidence,
        greaterThan(trader.minimumActionConfidence),
      );

      expect(swing.minimumIndependentFamiliesForAction, 3);
      expect(swing.holdOnMaterialConflict, isTrue);
      expect(swing.materialConflictThreshold, 0.55);

      // One absolute directional threshold is intentionally shared by
      // bullish and bearish decisions, preserving BUY/SELL parity.
      expect(swing.actionDirectionThreshold, 35);
      expect(swing.strongDirectionThreshold, 70);

      expect(
        RecommendationStrategyPolicy.forStrategy(StrategyType.investor),
        isNull,
      );

      expect(
        StrategyAnalysisPolicyCatalog.investor.isRecommendationActive,
        isFalse,
      );
    });

    test('current analysis-window VWAP stays excluded from Swing', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.vwapPosition,
      );

      expect(policy, isNotNull);
      expect(policy!.applicability, StrategyEvidenceApplicability.excluded);
      expect(policy.implementationReady, isFalse);
      expect(policy.isEligibleForEvaluation, isFalse);
      expect(policy.affectsDirection, isFalse);
      expect(policy.affectsConfidence, isFalse);
      expect(policy.affectsRiskOrEntryQuality, isFalse);
    });

    test('Investor remains fully deferred during v0.11', () {
      final investor = StrategyAnalysisPolicyCatalog.investor;

      expect(investor.implementationReadyEvidenceKinds, isEmpty);
      expect(investor.isRecommendationActive, isFalse);
    });
  });
}
