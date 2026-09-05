import '../../models/evidence_family.dart';
import '../engines/investor_recommendation_engine.dart';
import '../history/investor_historical_validation_service.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../providers/investor_capital_allocation_evidence_provider.dart';
import '../providers/investor_competitive_durability_evidence_provider.dart';
import '../providers/investor_data_providers.dart';
import '../providers/investor_evidence_provider.dart';
import '../providers/investor_financial_strength_evidence_provider.dart';
import '../providers/investor_growth_evidence_provider.dart';
import '../providers/investor_macro_sensitivity_evidence_provider.dart';
import '../providers/investor_ownership_positioning_evidence_provider.dart';
import '../providers/investor_profitability_quality_evidence_provider.dart';
import '../providers/investor_revisions_evidence_provider.dart';
import '../providers/investor_valuation_evidence_provider.dart';
import '../strategy/investor_market_expectations.dart';

class InvestorAnalysisResult {
  InvestorAnalysisResult({
    required this.snapshot,
    required List<InvestorEvidenceAssessment> assessments,
    required this.recommendationAnalysis,
    required this.marketExpectations,
    required this.historicalValidation,
  }) : assessments = List.unmodifiable(assessments);

  final InvestorPointInTimeSnapshot snapshot;
  final List<InvestorEvidenceAssessment> assessments;
  final InvestorRecommendationAnalysis recommendationAnalysis;
  final InvestorMarketExpectationsAssessment marketExpectations;
  final InvestorHistoricalValidationResult historicalValidation;

  bool get isSynthetic =>
      snapshot.containsSyntheticData ||
      historicalValidation.validation.isSynthetic;

  InvestorEvidenceAssessment? assessmentFor(EvidenceFamily family) {
    for (final assessment in assessments) {
      if (assessment.evidence.definition.family == family) {
        return assessment;
      }
    }
    return null;
  }
}

class InvestorAnalysisService {
  const InvestorAnalysisService({
    required this.fundamentalDataProvider,
    required this.analystEstimateProvider,
    required this.marketValuationDataProvider,
    required this.macroContextProvider,
    required this.sensitivityDataProvider,
    required this.ownershipPositioningProvider,
    required this.historicalValidationService,
    this.recommendationEngine = const InvestorRecommendationEngine(),
    this.marketExpectationsService = const InvestorMarketExpectationsService(),
    this.evidenceProviders = const [
      InvestorGrowthEvidenceProvider(),
      InvestorProfitabilityQualityEvidenceProvider(),
      InvestorFinancialStrengthEvidenceProvider(),
      InvestorCapitalAllocationEvidenceProvider(),
      InvestorValuationEvidenceProvider(),
      InvestorRevisionsEvidenceProvider(),
      InvestorCompetitiveDurabilityEvidenceProvider(),
      InvestorMacroSensitivityEvidenceProvider(),
      InvestorOwnershipPositioningEvidenceProvider(),
    ],
  });

  final FundamentalDataProvider fundamentalDataProvider;
  final AnalystEstimateProvider analystEstimateProvider;
  final MarketValuationDataProvider marketValuationDataProvider;
  final MacroContextProvider macroContextProvider;
  final InvestorSensitivityDataProvider sensitivityDataProvider;
  final OwnershipPositioningProvider ownershipPositioningProvider;
  final InvestorHistoricalValidationService historicalValidationService;

  final InvestorRecommendationEngine recommendationEngine;
  final InvestorMarketExpectationsService marketExpectationsService;
  final List<InvestorEvidenceProvider> evidenceProviders;

  Future<InvestorAnalysisResult> analyze({
    required String symbol,
    required DateTime analysisTime,
  }) async {
    final fundamentals = await fundamentalDataProvider.loadHistory(
      symbol: symbol,
      asOf: analysisTime,
    );
    final estimates = await analystEstimateProvider.loadEstimates(
      symbol: symbol,
      asOf: analysisTime,
    );
    final valuation = await marketValuationDataProvider.loadValuationContext(
      symbol: symbol,
      asOf: analysisTime,
    );
    final macro = await macroContextProvider.loadContext(
      symbol: symbol,
      asOf: analysisTime,
    );
    final sensitivityHistory = await sensitivityDataProvider
        .loadSensitivityHistory(symbol: symbol, asOf: analysisTime);
    final positioning = await ownershipPositioningProvider.loadPositioning(
      symbol: symbol,
      asOf: analysisTime,
    );

    final snapshot = InvestorPointInTimeSnapshot(
      symbol: symbol,
      analysisTime: analysisTime,
      fundamentals: fundamentals,
      estimates: estimates,
      market: valuation.market,
      valuationReferences: valuation.references,
      macro: macro,
      sensitivityHistory: sensitivityHistory,
      positioning: positioning,
    );

    if (!snapshot.isPointInTimeSafe) {
      throw StateError(
        'Investor analysis received information that was not available at the analysis time.',
      );
    }

    final assessments = evidenceProviders
        .map((provider) => provider.evaluate(snapshot))
        .toList(growable: false);

    final initialRecommendation = recommendationEngine.create(
      assessments: assessments,
      analysisTime: analysisTime,
    );

    final expectations = marketExpectationsService.build(
      assessments.map((assessment) => assessment.evidence),
    );

    final historicalValidation = await historicalValidationService.validate(
      symbol: symbol,
      analysis: initialRecommendation,
    );

    final finalRecommendation = recommendationEngine.applyHistoricalValidation(
      analysis: initialRecommendation,
      validation: historicalValidation.validation,
    );

    return InvestorAnalysisResult(
      snapshot: snapshot,
      assessments: assessments,
      recommendationAnalysis: finalRecommendation,
      marketExpectations: expectations,
      historicalValidation: historicalValidation,
    );
  }
}
