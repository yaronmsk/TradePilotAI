import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_kind.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';
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

      expect(swing.isRecommendationActive, isFalse);
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

      expect(swing.isRecommendationActive, isFalse);
    });

    test('uncalibrated Swing evidence remains blocked', () {
      final swing = StrategyAnalysisPolicyCatalog.swing;

      const pendingKinds = <EvidenceKind>[
        EvidenceKind.marketContext,
        EvidenceKind.marketBreadth,
        EvidenceKind.newsSentiment,
      ];

      for (final kind in pendingKinds) {
        final policy = swing.policyFor(kind);

        expect(policy, isNotNull);
        expect(
          policy!.implementationReady,
          isFalse,
          reason: '$kind must not execute for Swing before its own audit.',
        );
        expect(policy.canUseCurrentImplementation, isFalse);
      }
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
