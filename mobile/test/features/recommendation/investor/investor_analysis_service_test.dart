import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/investor/history/investor_historical_validation_service.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_estimate_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_historical_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_macro_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_ownership_positioning_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_valuation_data_provider.dart';
import 'package:mobile/features/recommendation/investor/services/investor_analysis_service.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';

const _macroProvider = MockInvestorMacroDataProvider();

const _service = InvestorAnalysisService(
  fundamentalDataProvider: MockInvestorFundamentalDataProvider(),
  analystEstimateProvider: MockInvestorEstimateProvider(),
  marketValuationDataProvider: MockInvestorValuationDataProvider(),
  macroContextProvider: _macroProvider,
  sensitivityDataProvider: _macroProvider,
  ownershipPositioningProvider: MockInvestorOwnershipPositioningProvider(),
  historicalValidationService: InvestorHistoricalValidationService(
    provider: MockInvestorHistoricalDataProvider(),
  ),
);

void main() {
  final analysisTime = DateTime(2026, 9, 5);

  test(
    'orchestrates the full Investor evidence set through one service',
    () async {
      final result = await _service.analyze(
        symbol: 'IVBULL',
        analysisTime: analysisTime,
      );

      expect(result.snapshot.isPointInTimeSafe, isTrue);
      expect(result.assessments, hasLength(9));
      expect(result.recommendationAnalysis.coreFamilyCount, 6);
      expect(
        result.recommendationAnalysis.requiredCoreFamiliesAvailable,
        isTrue,
      );
      expect(result.assessmentFor(EvidenceFamily.valuation), isNotNull);
      expect(result.assessmentFor(EvidenceFamily.marketContext), isNotNull);
      expect(
        result.assessmentFor(EvidenceFamily.ownershipPositioning),
        isNotNull,
      );
    },
  );

  test('development orchestration remains visibly synthetic', () async {
    final result = await _service.analyze(
      symbol: 'AAPL',
      analysisTime: analysisTime,
    );

    expect(result.isSynthetic, isTrue);
    expect(result.snapshot.containsSyntheticData, isTrue);
  });

  test(
    'historical validation remains attached as confidence-only overlay',
    () async {
      final result = await _service.analyze(
        symbol: 'IVBULL',
        analysisTime: analysisTime,
      );

      expect(
        result.historicalValidation.validation.status,
        HistoricalValidationStatus.available,
      );
      expect(
        result
            .recommendationAnalysis
            .recommendation
            .historicalValidation
            .status,
        HistoricalValidationStatus.available,
      );
      expect(
        result.recommendationAnalysis.recommendation.directionScore,
        isNotNull,
      );
    },
  );
}
