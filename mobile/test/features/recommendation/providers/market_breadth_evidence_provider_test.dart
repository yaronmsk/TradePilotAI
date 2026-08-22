import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/market_breadth_evidence_provider.dart';

void main() {
  const provider = MarketBreadthEvidenceProvider();

  test('maps healthy breadth into bullish Market Context evidence', () {
    const profile = MarketBreadthProfile(
      state: MarketBreadthState.healthy,
      advancingPercent: 62,
      above50DayPercent: 64,
      sectorParticipationPercent: 59,
      volatilityPercentile: 40,
      directionScore: 38,
      reliability: 0.9,
      summary: 'Healthy participation.',
    );

    final result = provider.evaluate(profile);

    expect(result.definition.family, EvidenceFamily.marketContext);
    expect(result.direction, EvidenceDirection.bullish);
    expect(result.reliability, 0.9);
  });

  test('keeps breadth unavailable when data is missing', () {
    final result = provider.evaluate(const MarketBreadthProfile.unavailable());

    expect(result.status, EvidenceStatus.insufficientData);
    expect(result.direction, EvidenceDirection.unknown);
  });
}
