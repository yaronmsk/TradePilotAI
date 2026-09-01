import '../models/investor_data_contracts.dart';
import 'investor_data_providers.dart';

class MockInvestorValuationDataProvider implements MarketValuationDataProvider {
  const MockInvestorValuationDataProvider();

  @override
  Future<InvestorValuationContext> loadValuationContext({
    required String symbol,
    required DateTime asOf,
  }) async {
    final profile = _profileFor(symbol.toUpperCase());

    final marketMetadata = InvestorDataMetadata(
      sourceName: 'Synthetic Investor market valuation',
      sourceType: InvestorDataSourceType.synthetic,
      observedAt: asOf,
      availableAt: asOf,
      isSynthetic: true,
    );

    final referenceMetadata = InvestorDataMetadata(
      sourceName: 'Synthetic Investor valuation references',
      sourceType: InvestorDataSourceType.synthetic,
      observedAt: asOf,
      availableAt: asOf,
      isSynthetic: true,
    );

    return InvestorValuationContext(
      market: [
        InvestorMetricPoint(
          metric: InvestorMarketMetric.marketCapitalization,
          value: profile.marketCapitalization,
          metadata: marketMetadata,
        ),
        InvestorMetricPoint(
          metric: InvestorMarketMetric.enterpriseValue,
          value: profile.enterpriseValue,
          metadata: marketMetadata,
        ),
      ],
      references: [
        InvestorValuationReference(
          multiple: InvestorValuationMultiple.priceToEarnings,
          ownHistoryMedian: profile.peOwnHistory,
          peerMedian: profile.pePeers,
          metadata: referenceMetadata,
        ),
        InvestorValuationReference(
          multiple: InvestorValuationMultiple.priceToFreeCashFlow,
          ownHistoryMedian: profile.pFcfOwnHistory,
          peerMedian: profile.pFcfPeers,
          metadata: referenceMetadata,
        ),
        InvestorValuationReference(
          multiple: InvestorValuationMultiple.enterpriseValueToOperatingProfit,
          ownHistoryMedian: profile.evOpOwnHistory,
          peerMedian: profile.evOpPeers,
          metadata: referenceMetadata,
        ),
      ],
    );
  }

  _MockValuationProfile _profileFor(String symbol) {
    return switch (symbol) {
      'IVBULL' => const _MockValuationProfile(
        marketCapitalization: 400,
        enterpriseValue: 375,
        peOwnHistory: 22,
        pePeers: 20,
        pFcfOwnHistory: 18,
        pFcfPeers: 16,
        evOpOwnHistory: 14,
        evOpPeers: 12,
      ),
      'IVBEAR' => const _MockValuationProfile(
        marketCapitalization: 120,
        enterpriseValue: 208,
        peOwnHistory: 18,
        pePeers: 20,
        pFcfOwnHistory: 15,
        pFcfPeers: 17,
        evOpOwnHistory: 14,
        evOpPeers: 16,
      ),
      'IVMIX' => const _MockValuationProfile(
        marketCapitalization: 250,
        enterpriseValue: 285,
        peOwnHistory: 20,
        pePeers: 22,
        pFcfOwnHistory: 16,
        pFcfPeers: 18,
        evOpOwnHistory: 16,
        evOpPeers: 17,
      ),
      _ => const _MockValuationProfile(
        marketCapitalization: 180,
        enterpriseValue: 190,
        peOwnHistory: 18,
        pePeers: 18,
        pFcfOwnHistory: 18,
        pFcfPeers: 18,
        evOpOwnHistory: 15,
        evOpPeers: 15,
      ),
    };
  }
}

class _MockValuationProfile {
  const _MockValuationProfile({
    required this.marketCapitalization,
    required this.enterpriseValue,
    required this.peOwnHistory,
    required this.pePeers,
    required this.pFcfOwnHistory,
    required this.pFcfPeers,
    required this.evOpOwnHistory,
    required this.evOpPeers,
  });

  final double marketCapitalization;
  final double enterpriseValue;
  final double peOwnHistory;
  final double pePeers;
  final double pFcfOwnHistory;
  final double pFcfPeers;
  final double evOpOwnHistory;
  final double evOpPeers;
}
