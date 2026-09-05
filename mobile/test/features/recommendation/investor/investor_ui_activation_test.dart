import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/history/investor_historical_validation_service.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_estimate_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_historical_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_macro_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_ownership_positioning_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_valuation_data_provider.dart';
import 'package:mobile/features/recommendation/investor/services/investor_analysis_service.dart';
import 'package:mobile/features/recommendation/investor/widgets/investor_analysis_dashboard.dart';

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
  testWidgets('Investor dashboard exposes human-readable dedicated sections', (
    tester,
  ) async {
    final result = await _service.analyze(
      symbol: 'IVBULL',
      analysisTime: DateTime(2026, 9, 5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InvestorAnalysisDashboard(result: result),
          ),
        ),
      ),
    );

    expect(find.text('Investor Analysis Context'), findsOneWidget);
    expect(find.text('Investor Recommendation'), findsOneWidget);
    expect(find.text('Investor Recommendation Insight'), findsOneWidget);
    expect(find.text('Business Strength'), findsOneWidget);
    expect(find.text('Valuation & Expectations'), findsOneWidget);
    expect(find.text('Global Market Context'), findsOneWidget);
    expect(find.text('Ownership & Positioning'), findsWidgets);
    expect(find.text('Investor Evidence'), findsOneWidget);
    expect(find.text('Investor Risk Context'), findsOneWidget);
    expect(find.text('Investor Historical Setup Validation'), findsOneWidget);
    expect(
      find.textContaining('Investor UI is active for validation'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.info_outline), findsWidgets);
    expect(find.textContaining('Primary candles analyzed'), findsNothing);
  });
}
