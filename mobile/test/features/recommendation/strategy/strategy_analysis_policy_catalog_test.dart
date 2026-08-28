import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_kind.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';
import 'package:mobile/features/recommendation/strategy/strategy_evidence_policy.dart';

void main() {
  group('StrategyAnalysisPolicyCatalog', () {
    test(
      'every strategy explicitly classifies every production evidence kind',
      () {
        for (final strategy in StrategyType.values) {
          final policy = StrategyAnalysisPolicyCatalog.forStrategy(strategy);

          expect(
            policy.coversAllProductionEvidenceKinds,
            isTrue,
            reason: '$strategy must classify every production EvidenceKind.',
          );

          expect(
            policy.isComplete,
            isTrue,
            reason: '$strategy must have complete strategy evidence decisions.',
          );
        }
      },
    );

    test('Trader remains the active validated strategy', () {
      final policy = StrategyAnalysisPolicyCatalog.trader;

      expect(policy.status, StrategyAnalysisPolicyStatus.active);
      expect(policy.isRecommendationActive, isTrue);

      expect(
        policy.evidencePolicies.values.every(
          (entry) =>
              entry.applicability ==
              StrategyEvidenceApplicability.reuseCurrentBehavior,
        ),
        isTrue,
      );

      expect(
        policy.eligibleEvidenceKinds.length,
        EvidenceKind.values.length - 1,
      );
    });

    test('Swing recommendation backend is active after Batch 7A', () {
      final policy = StrategyAnalysisPolicyCatalog.swing;

      expect(policy.status, StrategyAnalysisPolicyStatus.active);
      expect(policy.isRecommendationActive, isTrue);

      expect(
        policy.implementationReadyEvidenceKinds.toSet(),
        policy.eligibleEvidenceKinds.toSet(),
      );
    });

    test('calibrated Swing evidence is implementation-ready', () {
      final policy = StrategyAnalysisPolicyCatalog.swing;

      expect(policy.implementationReadyEvidenceKinds, <EvidenceKind>[
        EvidenceKind.candleTrend,
        EvidenceKind.rsi,
        EvidenceKind.relativeVolume,
        EvidenceKind.emaStructure,
        EvidenceKind.macdMomentum,
        EvidenceKind.supportResistance,
        EvidenceKind.volumeConfirmation,
        EvidenceKind.priceExtension,
        EvidenceKind.multiTimeframeTrend,
        EvidenceKind.marketContext,
        EvidenceKind.marketBreadth,
        EvidenceKind.newsSentiment,
      ]);

      final candleTrend = policy.policyFor(EvidenceKind.candleTrend);

      expect(candleTrend, isNotNull);
      expect(candleTrend!.implementationReady, isTrue);

      final emaStructure = policy.policyFor(EvidenceKind.emaStructure);

      expect(emaStructure, isNotNull);
      expect(emaStructure!.implementationReady, isTrue);
      expect(emaStructure.affectsDirection, isTrue);
      expect(emaStructure.affectsConfidence, isTrue);
    });

    test('Swing explicitly excludes current VWAP Position', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.vwapPosition,
      );

      expect(policy, isNotNull);
      expect(policy!.applicability, StrategyEvidenceApplicability.excluded);
      expect(policy.isEligibleForEvaluation, isFalse);
      expect(policy.affectsDirection, isFalse);
      expect(policy.affectsConfidence, isFalse);
      expect(policy.affectsRiskOrEntryQuality, isFalse);
    });

    test(
      'Swing Price Extension is confidence/risk-only and implementation-ready',
      () {
        final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
          EvidenceKind.priceExtension,
        );

        expect(policy, isNotNull);

        expect(
          policy!.applicability,
          StrategyEvidenceApplicability.recalibrateForStrategy,
        );

        expect(policy.implementationReady, isTrue);
        expect(policy.family, EvidenceFamily.volatility);
        expect(policy.affectsDirection, isFalse);
        expect(policy.affectsConfidence, isTrue);
        expect(policy.affectsRiskOrEntryQuality, isTrue);
        expect(policy.requiresStrategyCalibration, isTrue);

        expect(
          policy.calibrationNotes,
          contains('must not independently claim'),
        );
      },
    );

    test('Swing RSI requires strategy-specific trend-aware calibration', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.rsi,
      );

      expect(policy, isNotNull);
      expect(
        policy!.applicability,
        StrategyEvidenceApplicability.recalibrateForStrategy,
      );
      expect(policy.affectsDirection, isTrue);
      expect(policy.affectsConfidence, isTrue);
      expect(policy.affectsRiskOrEntryQuality, isTrue);
      expect(policy.calibrationNotes, isNotEmpty);
      expect(policy.implementationReady, isTrue);
    });

    test('Swing MACD uses strategy-specific momentum calibration', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.macdMomentum,
      );

      expect(policy, isNotNull);
      expect(
        policy!.applicability,
        StrategyEvidenceApplicability.recalibrateForStrategy,
      );
      expect(policy.implementationReady, isTrue);
      expect(policy.affectsDirection, isTrue);
      expect(policy.affectsConfidence, isTrue);
      expect(policy.affectsRiskOrEntryQuality, isFalse);
      expect(policy.calibrationNotes, isNotEmpty);
    });

    test('Swing Relative Volume is explicitly data-quality conditional', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.relativeVolume,
      );

      expect(policy, isNotNull);
      expect(
        policy!.applicability,
        StrategyEvidenceApplicability.conditionalOnDataQuality,
      );
      expect(policy.isEligibleForEvaluation, isTrue);
      expect(policy.implementationReady, isTrue);
      expect(policy.dataQualityRequirement, isNotEmpty);
      expect(policy.affectsDirection, isTrue);
      expect(policy.affectsConfidence, isTrue);
    });

    test('Swing Support & Resistance separates proximity from direction', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.supportResistance,
      );

      expect(policy, isNotNull);
      expect(
        policy!.applicability,
        StrategyEvidenceApplicability.recalibrateForStrategy,
      );
      expect(policy.implementationReady, isTrue);
      expect(policy.family, EvidenceFamily.priceStructure);
      expect(policy.affectsDirection, isTrue);
      expect(policy.affectsConfidence, isTrue);
      expect(policy.affectsRiskOrEntryQuality, isTrue);
      expect(policy.calibrationNotes, contains('Proximity alone'));
    });

    test(
      'Swing Volume Confirmation uses volatility-aware Participation calibration',
      () {
        final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
          EvidenceKind.volumeConfirmation,
        );

        expect(policy, isNotNull);
        expect(
          policy!.applicability,
          StrategyEvidenceApplicability.recalibrateForStrategy,
        );
        expect(policy.implementationReady, isTrue);
        expect(policy.family, EvidenceFamily.participation);
        expect(policy.affectsDirection, isTrue);
        expect(policy.affectsConfidence, isTrue);
        expect(policy.affectsRiskOrEntryQuality, isFalse);
        expect(policy.calibrationNotes, contains('volatility-aware'));
      },
    );

    test('Swing Market Context is calibrated and remains family-capped', () {
      final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
        EvidenceKind.marketContext,
      );

      expect(policy, isNotNull);
      expect(policy!.implementationReady, isTrue);
      expect(policy.family, EvidenceFamily.marketContext);
      expect(policy.affectsDirection, isTrue);
      expect(policy.affectsConfidence, isTrue);
      expect(policy.affectsRiskOrEntryQuality, isFalse);
      expect(
        policy.applicability,
        StrategyEvidenceApplicability.recalibrateForStrategy,
      );
      expect(policy.calibrationNotes, contains('stock-vs-market'));
    });

    test(
      'Swing Market Breadth is calibrated inside the Market Context family',
      () {
        final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
          EvidenceKind.marketBreadth,
        );

        expect(policy, isNotNull);
        expect(policy!.implementationReady, isTrue);
        expect(policy.family, EvidenceFamily.marketContext);
        expect(policy.affectsDirection, isTrue);
        expect(policy.affectsConfidence, isTrue);
        expect(policy.affectsRiskOrEntryQuality, isFalse);

        expect(
          policy.applicability,
          StrategyEvidenceApplicability.recalibrateForStrategy,
        );

        expect(policy.calibrationNotes, contains('de-duplicated'));
      },
    );

    test(
      'Swing News Sentiment is calibrated as directional Sentiment evidence',
      () {
        final policy = StrategyAnalysisPolicyCatalog.swing.policyFor(
          EvidenceKind.newsSentiment,
        );

        expect(policy, isNotNull);
        expect(policy!.implementationReady, isTrue);
        expect(policy.family, EvidenceFamily.sentiment);
        expect(policy.affectsDirection, isTrue);
        expect(policy.affectsConfidence, isTrue);
        expect(policy.affectsRiskOrEntryQuality, isFalse);

        expect(
          policy.applicability,
          StrategyEvidenceApplicability.recalibrateForStrategy,
        );

        expect(policy.calibrationNotes, contains('freshness'));

        expect(policy.calibrationNotes, contains('de-duplication'));
      },
    );

    test('Investor evidence semantics remain deferred to v0.12.0', () {
      final policy = StrategyAnalysisPolicyCatalog.investor;

      expect(policy.status, StrategyAnalysisPolicyStatus.planned);
      expect(policy.isRecommendationActive, isFalse);

      expect(
        policy.evidencePolicies.values.every(
          (entry) =>
              entry.applicability == StrategyEvidenceApplicability.deferred &&
              !entry.isEligibleForEvaluation &&
              !entry.affectsDirection &&
              !entry.affectsConfidence &&
              !entry.affectsRiskOrEntryQuality,
        ),
        isTrue,
      );
    });
  });
}
