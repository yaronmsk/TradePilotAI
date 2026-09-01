import '../../models/metric_explainability.dart';

enum InvestorMetricKind {
  revenueCagr,
  dilutedEpsCagr,
  freeCashFlowCagr,
  grossMarginTrend,
  operatingMarginQuality,
  freeCashFlowMarginQuality,
  returnOnInvestedCapitalQuality,
}

extension InvestorMetricKindPresentation on InvestorMetricKind {
  String get label {
    return switch (this) {
      InvestorMetricKind.revenueCagr => 'Revenue Growth',
      InvestorMetricKind.dilutedEpsCagr => 'EPS Growth',
      InvestorMetricKind.freeCashFlowCagr => 'Free Cash Flow Growth',
      InvestorMetricKind.grossMarginTrend => 'Gross Margin Trend',
      InvestorMetricKind.operatingMarginQuality => 'Operating Margin Quality',
      InvestorMetricKind.freeCashFlowMarginQuality =>
        'Free Cash Flow Margin Quality',
      InvestorMetricKind.returnOnInvestedCapitalQuality =>
        'Return on Invested Capital',
    };
  }
}

class InvestorMetricExplainabilityCatalog {
  InvestorMetricExplainabilityCatalog._();

  static const Map<InvestorMetricKind, MetricExplainability> definitions = {
    InvestorMetricKind.revenueCagr: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures the multi-year compound annual growth rate of company revenue.',
      calculation:
          'Uses the earliest and latest available annual revenue observations and converts the total change into an annualized compound growth rate. Batch 2 requires at least three point-in-time-safe observations.',
      whyItMatters:
          'Sustained revenue expansion can show that the company is increasing the economic base from which future profit and cash flow may be generated.',
      supportiveInterpretation:
          'Sustained positive revenue growth supports the Investor Growth family.',
      opposingInterpretation:
          'Sustained revenue contraction opposes the long-term growth thesis.',
      neutralInterpretation:
          'Very low or nearly flat annualized revenue growth provides limited directional evidence.',
      recommendationImpact:
          'Revenue Growth is one input inside the capped Growth family. It is not an independent recommendation vote and cannot activate Investor recommendations in Batch 2.',
      limitations:
          'Revenue growth does not prove profitable growth. Acquisitions, inflation, cyclicality and accounting changes can affect reported revenue. Sector-relative growth calibration is not yet applied in Batch 2.',
    ),
    InvestorMetricKind.dilutedEpsCagr: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures the multi-year compound annual growth rate of diluted earnings per share when a positive CAGR is mathematically meaningful.',
      calculation:
          'Uses point-in-time-safe annual diluted EPS observations. CAGR is withheld when the starting or ending EPS is non-positive because percentage compounding across zero can be misleading.',
      whyItMatters:
          'Per-share earnings growth can show whether business improvement is reaching shareholders after dilution.',
      supportiveInterpretation:
          'Sustained positive diluted EPS growth supports long-term Growth evidence.',
      opposingInterpretation:
          'Sustained contraction in positive diluted EPS opposes long-term Growth evidence.',
      neutralInterpretation:
          'Small changes provide limited directional evidence; invalid sign-crossing histories are marked unavailable rather than forced into a score.',
      recommendationImpact:
          'EPS Growth refines the Growth family and is de-duplicated with Revenue and Free Cash Flow Growth rather than counted as another independent family.',
      limitations:
          'EPS can be affected by non-cash items, capital structure, buybacks, dilution and one-off accounting effects. Negative-to-positive transitions require a different future treatment than CAGR.',
    ),
    InvestorMetricKind.freeCashFlowCagr: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures the multi-year compound annual growth rate of free cash flow when the starting and ending values are positive.',
      calculation:
          'Annualizes the change between the earliest and latest point-in-time-safe free-cash-flow observations. Non-positive endpoints are withheld from CAGR rather than producing misleading percentages.',
      whyItMatters:
          'Growing free cash flow can increase the company’s ability to reinvest, reduce debt, repurchase shares or return cash to shareholders.',
      supportiveInterpretation:
          'Sustained positive free-cash-flow growth supports the Growth family.',
      opposingInterpretation:
          'Sustained contraction in positive free cash flow opposes the Growth family.',
      neutralInterpretation:
          'Small changes provide little directional evidence.',
      recommendationImpact:
          'Free Cash Flow Growth contributes inside the capped Growth family and cannot become a separate independent vote.',
      limitations:
          'Free cash flow can be volatile because of working capital and capital expenditure cycles. Sector/business-model normalization is not yet applied.',
    ),
    InvestorMetricKind.grossMarginTrend: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures whether gross margin is improving or deteriorating over the available multi-year history.',
      calculation:
          'Compares the earliest and latest point-in-time-safe gross-margin percentages. Batch 2 scores the direction of the change, not the absolute gross-margin level, because normal gross margins differ materially by industry.',
      whyItMatters:
          'Persistent gross-margin improvement can indicate improving product economics, pricing or cost efficiency, while compression can signal pressure.',
      supportiveInterpretation:
          'A sustained increase in gross margin supports Profitability & Quality evidence.',
      opposingInterpretation:
          'A sustained decline in gross margin opposes Profitability & Quality evidence.',
      neutralInterpretation:
          'A largely stable gross margin provides limited directional evidence.',
      recommendationImpact:
          'Gross Margin Trend is one de-duplicated input inside Profitability & Quality.',
      limitations:
          'Industry cost structures differ substantially. Batch 2 deliberately does not compare absolute gross-margin levels across sectors; peer-relative calibration is deferred until reliable peer distributions exist.',
    ),
    InvestorMetricKind.operatingMarginQuality: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Evaluates operating-margin economics using both profitability direction and whether operations are above or below break-even.',
      calculation:
          'Combines multi-year operating-margin change with a bounded level component centered on zero operating margin. The level component distinguishes positive from negative operating economics without claiming a universal sector-specific target.',
      whyItMatters:
          'Operating margin shows how much operating profit remains after core operating expenses and whether business economics are improving or weakening.',
      supportiveInterpretation:
          'Positive and/or improving operating profitability supports Profitability & Quality.',
      opposingInterpretation:
          'Negative and/or deteriorating operating profitability opposes Profitability & Quality.',
      neutralInterpretation:
          'Stable economics near the neutral boundary provide limited directional evidence.',
      recommendationImpact:
          'Operating Margin Quality refines the Profitability & Quality family and is not a separate family vote.',
      limitations:
          'Normal operating margins vary by sector and business model. Batch 2 uses zero as an economic break-even reference and trajectory, not a universal “good margin” threshold.',
    ),
    InvestorMetricKind.freeCashFlowMarginQuality: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Evaluates free-cash-flow margin using its multi-year direction and whether cash conversion is positive or negative.',
      calculation:
          'Combines the percentage-point change in free-cash-flow margin with a bounded level component centered on zero.',
      whyItMatters:
          'Free-cash-flow margin helps show whether reported revenue converts into cash that can support long-term shareholder value.',
      supportiveInterpretation:
          'Positive and/or improving free-cash-flow margin supports Profitability & Quality.',
      opposingInterpretation:
          'Negative and/or deteriorating free-cash-flow margin opposes Profitability & Quality.',
      neutralInterpretation:
          'Stable cash margins near the neutral boundary provide limited directional evidence.',
      recommendationImpact:
          'Free Cash Flow Margin Quality contributes only inside Profitability & Quality.',
      limitations:
          'Working-capital timing and capital expenditure cycles can distort individual years. Sector-relative level calibration is deferred.',
    ),
    InvestorMetricKind.returnOnInvestedCapitalQuality: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Evaluates the company’s return on invested capital using current sign and multi-year direction.',
      calculation:
          'Combines the change in ROIC across the available history with a bounded level component centered on zero. Batch 2 does not claim one universal “excellent ROIC” threshold.',
      whyItMatters:
          'ROIC helps indicate whether management converts invested operating capital into economic returns efficiently.',
      supportiveInterpretation:
          'Positive and/or improving ROIC supports Profitability & Quality.',
      opposingInterpretation:
          'Negative and/or deteriorating ROIC opposes Profitability & Quality.',
      neutralInterpretation:
          'Stable ROIC close to the neutral boundary provides limited directional evidence.',
      recommendationImpact:
          'ROIC is one input inside Profitability & Quality and is de-duplicated with margin evidence.',
      limitations:
          'ROIC definitions and normal levels vary by sector, accounting treatment and business model. Peer-relative calibration and cost-of-capital comparison are deferred.',
    ),
  };

  static MetricExplainability forKind(InvestorMetricKind kind) =>
      definitions[kind]!;

  static bool get isComplete =>
      definitions.length == InvestorMetricKind.values.length &&
      InvestorMetricKind.values.every(
        (kind) => definitions[kind]?.isComplete ?? false,
      );
}
