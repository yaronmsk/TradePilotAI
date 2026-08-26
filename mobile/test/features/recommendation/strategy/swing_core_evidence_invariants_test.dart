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

  group('Swing Batch 3 core evidence invariants', () {
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

    test('uncalibrated Swing evidence remains blocked', () {
      final swing = StrategyAnalysisPolicyCatalog.swing;

      const pendingKinds = <EvidenceKind>[
        EvidenceKind.supportResistance,
        EvidenceKind.volumeConfirmation,
        EvidenceKind.priceExtension,
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
