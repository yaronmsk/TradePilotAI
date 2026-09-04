import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../../models/metric_explainability.dart';

enum InvestorMarketExpectationsLevel {
  conservative,
  balanced,
  demanding,
  veryDemanding,
  insufficientData,
}

extension InvestorMarketExpectationsLevelPresentation
    on InvestorMarketExpectationsLevel {
  String get label => switch (this) {
    InvestorMarketExpectationsLevel.conservative =>
      'Expectations look conservative',
    InvestorMarketExpectationsLevel.balanced => 'Expectations look balanced',
    InvestorMarketExpectationsLevel.demanding => 'Expectations look demanding',
    InvestorMarketExpectationsLevel.veryDemanding =>
      'Expectations look very demanding',
    InvestorMarketExpectationsLevel.insufficientData => 'Not enough data',
  };
}

class InvestorMarketExpectationsAssessment {
  InvestorMarketExpectationsAssessment({
    required this.level,
    required this.businessSignal,
    required this.valuationSignal,
    required this.expectationsPressure,
    required this.positioningContext,
    required List<EvidenceFamily> usedFamilies,
    required this.explanation,
    required this.explainability,
  }) : usedFamilies = List.unmodifiable(usedFamilies);

  final InvestorMarketExpectationsLevel level;
  final double businessSignal;
  final double valuationSignal;
  final double expectationsPressure;
  final String positioningContext;
  final List<EvidenceFamily> usedFamilies;
  final String explanation;
  final MetricExplainability explainability;

  bool get hasSufficientData =>
      level != InvestorMarketExpectationsLevel.insufficientData;
}

class InvestorMarketExpectationsService {
  const InvestorMarketExpectationsService();

  /// Permanent zero-vote helper contract.
  static const bool addsEvidenceVotes = false;
  static const bool addsDirectionPoints = false;
  static const bool addsConfidencePoints = false;

  static const MetricExplainability explainability = MetricExplainability(
    semanticRole: MetricSemanticRole.contextConfiguration,
    whatItIs:
        'A presentation helper that compares already-counted business evidence with already-counted valuation evidence to describe how demanding current market expectations appear.',
    calculation:
        'Requires Valuation plus at least two available business families from Growth, Profitability & Quality and Revisions. It reconstructs signed family strength from those already-counted results, compares business support with valuation pressure and optionally summarizes Ownership & Positioning as context.',
    whyItMatters:
        'A strong business can still be priced for very demanding execution, while a weaker business can sometimes trade at conservative expectations. Separating business quality from what appears priced in helps a long-term investor interpret the recommendation evidence.',
    recommendationImpact:
        'This helper adds zero evidence votes, zero direction points and zero confidence points. It only summarizes evidence that has already been counted elsewhere.',
    limitations:
        'This is not a market-implied forecast, fair-value model, DCF, price target or probability of return. The deterministic pressure bands are presentation heuristics and must not be reused as recommendation weights.',
  );

  InvestorMarketExpectationsAssessment build(
    Iterable<EvidenceResult> evidence,
  ) {
    final available = {
      for (final result in evidence)
        if (result.isAvailable) result.definition.family: result,
    };

    final valuation = available[EvidenceFamily.valuation];
    final business = [
      available[EvidenceFamily.growth],
      available[EvidenceFamily.profitabilityQuality],
      available[EvidenceFamily.revisions],
    ].whereType<EvidenceResult>().toList(growable: false);

    final positioning = available[EvidenceFamily.ownershipPositioning];

    if (valuation == null || business.length < 2) {
      return InvestorMarketExpectationsAssessment(
        level: InvestorMarketExpectationsLevel.insufficientData,
        businessSignal: 0,
        valuationSignal: valuation == null ? 0 : _signed(valuation),
        expectationsPressure: 0,
        positioningContext: _positioningContext(positioning),
        usedFamilies: [
          ...business.map((result) => result.definition.family),
          if (valuation != null) EvidenceFamily.valuation,
          if (positioning != null) EvidenceFamily.ownershipPositioning,
        ],
        explanation:
            'Market Expectations requires an available Valuation family and at least two available business families from Growth, Profitability & Quality and Revisions.',
        explainability: explainability,
      );
    }

    final businessSignal =
        business.map(_signed).reduce((a, b) => a + b) / business.length;
    final valuationSignal = _signed(valuation);

    // Expensive/opposing valuation increases pressure. Strong business
    // evidence offsets some of that pressure; weak business evidence raises it.
    // Ownership/Positioning is displayed as context but does not alter the
    // classification, preventing another hidden vote.
    final pressure = ((-valuationSignal * 0.65) + (-businessSignal * 0.35))
        .clamp(-100.0, 100.0)
        .toDouble();

    final level = pressure <= -25
        ? InvestorMarketExpectationsLevel.conservative
        : pressure < 25
        ? InvestorMarketExpectationsLevel.balanced
        : pressure < 55
        ? InvestorMarketExpectationsLevel.demanding
        : InvestorMarketExpectationsLevel.veryDemanding;

    final positioningContext = _positioningContext(positioning);

    return InvestorMarketExpectationsAssessment(
      level: level,
      businessSignal: businessSignal,
      valuationSignal: valuationSignal,
      expectationsPressure: pressure,
      positioningContext: positioningContext,
      usedFamilies: [
        ...business.map((result) => result.definition.family),
        EvidenceFamily.valuation,
        if (positioning != null) EvidenceFamily.ownershipPositioning,
      ],
      explanation:
          '${level.label}. Business evidence is ${_describeSignal(businessSignal)}, while relative valuation is ${_describeValuation(valuationSignal)}. '
          '$positioningContext This helper does not add another recommendation vote.',
      explainability: explainability,
    );
  }

  double _signed(EvidenceResult result) {
    return switch (result.direction) {
      EvidenceDirection.bullish => result.score,
      EvidenceDirection.bearish => -result.score,
      EvidenceDirection.neutral || EvidenceDirection.unknown => 0,
    };
  }

  String _positioningContext(EvidenceResult? result) {
    if (result == null) {
      return 'Ownership & Positioning context is not available.';
    }

    return switch (result.direction) {
      EvidenceDirection.bullish =>
        'Published Ownership & Positioning trends are supportive context.',
      EvidenceDirection.bearish =>
        'Published Ownership & Positioning trends are opposing context.',
      EvidenceDirection.neutral =>
        'Published Ownership & Positioning trends are mixed / neutral context.',
      EvidenceDirection.unknown =>
        'Ownership & Positioning context is not conclusive.',
    };
  }

  String _describeSignal(double signal) {
    if (signal >= 35) {
      return 'strongly supportive';
    }
    if (signal >= 10) {
      return 'supportive';
    }
    if (signal <= -35) {
      return 'materially opposing';
    }
    if (signal <= -10) {
      return 'opposing';
    }
    return 'mixed / neutral';
  }

  String _describeValuation(double signal) {
    if (signal >= 35) {
      return 'supportive / relatively inexpensive';
    }
    if (signal >= 10) {
      return 'somewhat supportive';
    }
    if (signal <= -35) {
      return 'opposing / relatively expensive';
    }
    if (signal <= -10) {
      return 'somewhat demanding';
    }
    return 'roughly balanced';
  }
}
