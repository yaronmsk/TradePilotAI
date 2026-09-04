import '../models/investor_data_contracts.dart';
import 'investor_data_providers.dart';

class MockInvestorOwnershipPositioningProvider
    implements OwnershipPositioningProvider {
  const MockInvestorOwnershipPositioningProvider();

  @override
  Future<List<InvestorMetricPoint<InvestorPositioningMetric>>> loadPositioning({
    required String symbol,
    required DateTime asOf,
  }) async {
    final profile = _profileFor(symbol.toUpperCase());
    final points = <InvestorMetricPoint<InvestorPositioningMetric>>[];

    final institutionalObservedOffsets = [190, 100, 55];
    final institutionalAvailableOffsets = [145, 55, 10];

    for (var index = 0; index < institutionalObservedOffsets.length; index++) {
      final observedAt = asOf.subtract(
        Duration(days: institutionalObservedOffsets[index]),
      );
      final availableAt = asOf.subtract(
        Duration(days: institutionalAvailableOffsets[index]),
      );

      InvestorDataMetadata metadata() => InvestorDataMetadata(
        sourceName: 'Synthetic Investor institutional ownership filing',
        sourceType: InvestorDataSourceType.synthetic,
        observedAt: observedAt,
        availableAt: availableAt,
        isSynthetic: true,
      );

      points.addAll([
        InvestorMetricPoint(
          metric: InvestorPositioningMetric.institutionalOwnershipPercent,
          value: profile.institutionalOwnershipPercent[index],
          metadata: metadata(),
        ),
        InvestorMetricPoint(
          metric: InvestorPositioningMetric.institutionalHolderCount,
          value: profile.institutionalHolderCount[index],
          metadata: metadata(),
        ),
      ]);
    }

    final shortObservedOffsets = [35, 20, 5];
    final shortAvailableOffsets = [30, 15, 0];

    for (var index = 0; index < shortObservedOffsets.length; index++) {
      final observedAt = asOf.subtract(
        Duration(days: shortObservedOffsets[index]),
      );
      final availableAt = asOf.subtract(
        Duration(days: shortAvailableOffsets[index]),
      );

      points.add(
        InvestorMetricPoint(
          metric: InvestorPositioningMetric.shortInterestPercentFloat,
          value: profile.shortInterestPercentFloat[index],
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic Investor short-interest position',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: observedAt,
            availableAt: availableAt,
            isSynthetic: true,
          ),
        ),
      );
    }

    // Deliberately supplied but not directionally interpreted in Batch 7.
    points.add(
      InvestorMetricPoint(
        metric: InvestorPositioningMetric.insiderNetShares,
        value: profile.insiderNetShares,
        metadata: InvestorDataMetadata(
          sourceName: 'Synthetic raw insider net shares',
          sourceType: InvestorDataSourceType.synthetic,
          observedAt: asOf.subtract(const Duration(days: 4)),
          availableAt: asOf.subtract(const Duration(days: 2)),
          isSynthetic: true,
        ),
      ),
    );

    return List.unmodifiable(points);
  }

  _MockOwnershipProfile _profileFor(String symbol) {
    return switch (symbol) {
      'IVBULL' => const _MockOwnershipProfile(
        institutionalOwnershipPercent: [58, 61, 64],
        institutionalHolderCount: [320, 345, 370],
        shortInterestPercentFloat: [7.0, 5.8, 4.6],
        insiderNetShares: 25000,
      ),
      'IVBEAR' => const _MockOwnershipProfile(
        institutionalOwnershipPercent: [64, 61, 57],
        institutionalHolderCount: [400, 370, 335],
        shortInterestPercentFloat: [4.5, 6.2, 8.5],
        insiderNetShares: -30000,
      ),
      'IVMIX' => const _MockOwnershipProfile(
        institutionalOwnershipPercent: [55, 58, 57],
        institutionalHolderCount: [300, 320, 318],
        shortInterestPercentFloat: [6.0, 6.5, 6.0],
        insiderNetShares: 5000,
      ),
      _ => const _MockOwnershipProfile(
        institutionalOwnershipPercent: [60, 60.2, 60.1],
        institutionalHolderCount: [340, 342, 341],
        shortInterestPercentFloat: [5.5, 5.6, 5.5],
        insiderNetShares: 0,
      ),
    };
  }
}

class _MockOwnershipProfile {
  const _MockOwnershipProfile({
    required this.institutionalOwnershipPercent,
    required this.institutionalHolderCount,
    required this.shortInterestPercentFloat,
    required this.insiderNetShares,
  });

  final List<double> institutionalOwnershipPercent;
  final List<double> institutionalHolderCount;
  final List<double> shortInterestPercentFloat;
  final double insiderNetShares;
}
