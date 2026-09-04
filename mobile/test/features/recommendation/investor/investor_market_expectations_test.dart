import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_market_expectations.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const service = InvestorMarketExpectationsService();

  EvidenceResult evidence(
    EvidenceFamily family,
    EvidenceDirection direction,
    double score,
  ) {
    return EvidenceResult(
      providerName: family.label,
      definition: EvidenceDefinition(
        family: family,
        name: family.label,
        description: 'Test evidence',
        whyItMatters: 'Test evidence',
        calculation: 'Test evidence',
      ),
      status: EvidenceStatus.available,
      direction: direction,
      strength: EvidenceStrength.strong,
      score: score,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 1,
      currentValue: 'Test',
      baselineValue: 'Test',
      relativeValue: 'Test',
      explanation: 'Test',
    );
  }

  test('strong business plus inexpensive valuation looks conservative', () {
    final result = service.build([
      evidence(EvidenceFamily.growth, EvidenceDirection.bullish, 70),
      evidence(
        EvidenceFamily.profitabilityQuality,
        EvidenceDirection.bullish,
        65,
      ),
      evidence(EvidenceFamily.revisions, EvidenceDirection.bullish, 55),
      evidence(EvidenceFamily.valuation, EvidenceDirection.bullish, 75),
    ]);

    expect(result.level, InvestorMarketExpectationsLevel.conservative);
    expect(result.hasSufficientData, isTrue);
    expect(result.explainability.isComplete, isTrue);
  });

  test('expensive valuation can make otherwise strong business demanding', () {
    final result = service.build([
      evidence(EvidenceFamily.growth, EvidenceDirection.bullish, 45),
      evidence(
        EvidenceFamily.profitabilityQuality,
        EvidenceDirection.bullish,
        40,
      ),
      evidence(EvidenceFamily.revisions, EvidenceDirection.bullish, 35),
      evidence(EvidenceFamily.valuation, EvidenceDirection.bearish, 80),
    ]);

    expect(result.level, InvestorMarketExpectationsLevel.demanding);
  });

  test('expensive valuation plus weak business can look very demanding', () {
    final result = service.build([
      evidence(EvidenceFamily.growth, EvidenceDirection.bearish, 60),
      evidence(
        EvidenceFamily.profitabilityQuality,
        EvidenceDirection.bearish,
        50,
      ),
      evidence(EvidenceFamily.revisions, EvidenceDirection.bearish, 45),
      evidence(EvidenceFamily.valuation, EvidenceDirection.bearish, 85),
    ]);

    expect(result.level, InvestorMarketExpectationsLevel.veryDemanding);
  });

  test('valuation and at least two business families are required', () {
    final result = service.build([
      evidence(EvidenceFamily.growth, EvidenceDirection.bullish, 50),
      evidence(EvidenceFamily.revisions, EvidenceDirection.bullish, 50),
    ]);

    expect(result.level, InvestorMarketExpectationsLevel.insufficientData);
    expect(result.hasSufficientData, isFalse);
  });

  test('Market Expectations is permanently zero vote', () {
    expect(InvestorMarketExpectationsService.addsEvidenceVotes, isFalse);
    expect(InvestorMarketExpectationsService.addsDirectionPoints, isFalse);
    expect(InvestorMarketExpectationsService.addsConfidencePoints, isFalse);
  });
}
