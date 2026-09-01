import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';

void main() {
  test('metadata gates historical use by publication availability', () {
    final metadata = InvestorDataMetadata(
      sourceName: 'Regulatory filing',
      sourceType: InvestorDataSourceType.regulatoryFiling,
      observedAt: DateTime(2026, 6, 30),
      availableAt: DateTime(2026, 8, 1),
    );

    expect(metadata.isAvailableAt(DateTime(2026, 7, 31)), isFalse);
    expect(metadata.isAvailableAt(DateTime(2026, 8, 1)), isTrue);
    expect(metadata.isAvailableAt(DateTime(2026, 8, 2)), isTrue);
  });

  test('point-in-time snapshot rejects future-known observations', () {
    final snapshot = InvestorPointInTimeSnapshot(
      symbol: 'TEST',
      analysisTime: DateTime(2026, 7, 15),
      fundamentals: [
        InvestorMetricPoint(
          metric: InvestorFundamentalMetric.revenue,
          value: 100,
          metadata: InvestorDataMetadata(
            sourceName: 'Future filing',
            sourceType: InvestorDataSourceType.regulatoryFiling,
            observedAt: DateTime(2026, 6, 30),
            availableAt: DateTime(2026, 8, 1),
          ),
        ),
      ],
    );

    expect(snapshot.isPointInTimeSafe, isFalse);
  });

  test('snapshot explicitly exposes synthetic development data', () {
    final snapshot = InvestorPointInTimeSnapshot(
      symbol: 'TEST',
      analysisTime: DateTime(2026, 9, 1),
      macro: [
        InvestorMetricPoint(
          metric: InvestorMacroMetric.policyRate,
          value: 4.25,
          metadata: InvestorDataMetadata(
            sourceName: 'Mock macro',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: DateTime(2026, 8, 31),
            availableAt: DateTime(2026, 8, 31),
            isSynthetic: true,
          ),
        ),
      ],
    );

    expect(snapshot.isPointInTimeSafe, isTrue);
    expect(snapshot.containsSyntheticData, isTrue);
  });
}
