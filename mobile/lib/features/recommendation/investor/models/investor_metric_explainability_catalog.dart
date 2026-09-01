import '../../models/metric_explainability.dart';

enum InvestorMetricKind {
  revenueCagr,
  dilutedEpsCagr,
  freeCashFlowCagr,
  grossMarginTrend,
  operatingMarginQuality,
  freeCashFlowMarginQuality,
  returnOnInvestedCapitalQuality,
  netDebtToFreeCashFlow,
  interestCoverage,
  cashToDebt,
  netShareCountChange,
  stockBasedCompensationBurden,
  cashReturnFunding,
  priceToEarningsRelative,
  priceToFreeCashFlowRelative,
  enterpriseValueToOperatingProfitRelative,
  revenueEstimateRevision,
  dilutedEpsEstimateRevision,
  freeCashFlowEstimateRevision,
  returnOnInvestedCapitalPersistence,
  operatingMarginPersistence,
  freeCashFlowPersistence,
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
      InvestorMetricKind.netDebtToFreeCashFlow => 'Net Debt / Free Cash Flow',
      InvestorMetricKind.interestCoverage => 'Interest Coverage',
      InvestorMetricKind.cashToDebt => 'Cash / Debt',
      InvestorMetricKind.netShareCountChange => 'Net Share Count Change',
      InvestorMetricKind.stockBasedCompensationBurden =>
        'Stock-Based Compensation Burden',
      InvestorMetricKind.cashReturnFunding => 'Cash Return Funding',
      InvestorMetricKind.priceToEarningsRelative => 'P/E vs Benchmarks',
      InvestorMetricKind.priceToFreeCashFlowRelative =>
        'Price / Free Cash Flow vs Benchmarks',
      InvestorMetricKind.enterpriseValueToOperatingProfitRelative =>
        'EV / Operating Profit vs Benchmarks',
      InvestorMetricKind.revenueEstimateRevision => 'Revenue Estimate Revision',
      InvestorMetricKind.dilutedEpsEstimateRevision => 'EPS Estimate Revision',
      InvestorMetricKind.freeCashFlowEstimateRevision =>
        'Free Cash Flow Estimate Revision',
      InvestorMetricKind.returnOnInvestedCapitalPersistence =>
        'ROIC Persistence',
      InvestorMetricKind.operatingMarginPersistence =>
        'Operating Margin Persistence',
      InvestorMetricKind.freeCashFlowPersistence =>
        'Free Cash Flow Persistence',
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
    InvestorMetricKind.netDebtToFreeCashFlow: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Compares debt net of cash with annual free cash flow for an ordinary non-financial operating company.',
      calculation:
          'Subtracts cash from total debt and divides the result by current positive free cash flow. Net cash is supportive; progressively larger positive multiples receive progressively more opposing scores.',
      whyItMatters:
          'A company with heavy net debt relative to internally generated cash may have less flexibility to survive downturns, invest or refinance safely.',
      supportiveInterpretation:
          'Net cash or low net debt relative to free cash flow supports Financial Strength.',
      opposingInterpretation:
          'High net debt relative to free cash flow, especially alongside non-positive FCF, opposes Financial Strength.',
      neutralInterpretation:
          'Moderate leverage provides limited directional evidence.',
      recommendationImpact:
          'Net Debt / FCF is one input inside Financial Strength and cannot become a separate family vote.',
      limitations:
          'The ratio ignores debt maturities, lease obligations and off-balance-sheet commitments. Generic thresholds are provisional and invalid for banks/insurers.',
    ),
    InvestorMetricKind.interestCoverage: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Estimates how many times operating profit covers reported interest expense.',
      calculation:
          'Estimates operating profit as revenue multiplied by operating margin, then divides by positive interest expense.',
      whyItMatters:
          'Weak coverage can indicate that debt service is consuming too much operating profit.',
      supportiveInterpretation:
          'High operating-profit coverage of interest supports Financial Strength.',
      opposingInterpretation:
          'Coverage near or below one times opposes Financial Strength.',
      neutralInterpretation:
          'Intermediate coverage provides limited directional evidence.',
      recommendationImpact:
          'Interest Coverage contributes only inside the Financial Strength family.',
      limitations:
          'Operating income and interest expense can be affected by accounting classification, cyclicality and one-off items. This is not a credit rating.',
    ),
    InvestorMetricKind.cashToDebt: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs: 'Compares current cash and equivalents with total debt.',
      calculation:
          'Divides cash and equivalents by total debt, with debt-free companies treated as having the strongest cash/debt position.',
      whyItMatters:
          'A larger cash cushion can provide refinancing flexibility and reduce balance-sheet stress.',
      supportiveInterpretation:
          'Cash covering a large share of debt supports Financial Strength.',
      opposingInterpretation:
          'Very little cash relative to debt opposes Financial Strength.',
      neutralInterpretation: 'Intermediate cash/debt coverage is mixed.',
      recommendationImpact:
          'Cash / Debt is de-duplicated inside Financial Strength with the other leverage measures.',
      limitations:
          'Cash may be restricted or needed for operations, and debt maturity timing is not modeled. Sector-specific balance-sheet structures require separate treatment.',
    ),
    InvestorMetricKind.netShareCountChange: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures the multi-year net change in shares outstanding after buybacks, stock issuance and equity compensation.',
      calculation:
          'Compares the earliest and latest positive share-count observations. Falling share count is supportive; rising share count indicates dilution.',
      whyItMatters:
          'Business growth creates less per-share value when each shareholder owns a progressively smaller fraction of the company.',
      supportiveInterpretation:
          'A sustained net reduction in shares supports Capital Allocation & Dilution.',
      opposingInterpretation:
          'Persistent net share issuance/dilution opposes Capital Allocation & Dilution.',
      neutralInterpretation: 'A broadly stable share count is neutral.',
      recommendationImpact:
          'Net Share Count Change receives the largest weight inside Capital Allocation & Dilution.',
      limitations:
          'Share-count reduction is not automatically value-creating if buybacks were executed at excessive prices. This metric measures ownership dilution, not repurchase valuation.',
    ),
    InvestorMetricKind.stockBasedCompensationBurden: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures current stock-based compensation as a percentage of revenue.',
      calculation:
          'Divides stock-based compensation by positive revenue and applies transparent provisional burden bands.',
      whyItMatters:
          'Heavy equity compensation can transfer a meaningful share of business value to employees and offset headline repurchase programs.',
      supportiveInterpretation:
          'A contained SBC burden can modestly support capital-allocation discipline.',
      opposingInterpretation:
          'A very high SBC burden opposes per-share capital-allocation quality.',
      neutralInterpretation: 'Moderate SBC burden is neutral.',
      recommendationImpact:
          'SBC Burden contributes inside Capital Allocation & Dilution and is not an independent vote.',
      limitations:
          'Normal SBC varies widely by industry and company maturity. Batch 3 thresholds are provisional and require later peer-relative calibration.',
    ),
    InvestorMetricKind.cashReturnFunding: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Compares dividends plus gross share repurchases with current free cash flow.',
      calculation:
          'Adds positive dividend and repurchase cash amounts and divides by positive FCF. No payout is neutral; well-funded payouts receive only modest positive influence; materially over-funded payouts receive opposing influence.',
      whyItMatters:
          'Repeatedly returning more cash than the business generates can consume balance-sheet capacity or require debt/issuance.',
      supportiveInterpretation:
          'Cash returns comfortably funded within free cash flow can modestly support capital-allocation discipline.',
      opposingInterpretation:
          'Cash returns materially exceeding free cash flow oppose capital-allocation sustainability.',
      neutralInterpretation:
          'No payout or roughly fully funded payouts can remain neutral.',
      recommendationImpact:
          'Cash Return Funding has bounded influence inside Capital Allocation & Dilution; larger payouts are not treated as automatically better.',
      limitations:
          'A company can rationally use accumulated cash or temporary borrowing, and reinvestment can be preferable to distributions. Gross buybacks do not reveal whether dilution was actually offset, so Net Share Count Change remains a separate input in the same family.',
    ),
    InvestorMetricKind.priceToEarningsRelative: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Compares the company’s current positive-earnings P/E multiple with its own historical median and/or a relevant peer median.',
      calculation:
          'Divides market capitalization by positive net income, then measures the percentage premium or discount versus each valid point-in-time benchmark. Negative or zero earnings make P/E unavailable rather than artificially cheap.',
      whyItMatters:
          'P/E can show how much investors currently pay for each unit of reported earnings relative to explicit comparison anchors.',
      supportiveInterpretation:
          'A meaningful discount to valid historical/peer P/E benchmarks supports Valuation evidence.',
      opposingInterpretation:
          'A meaningful premium to valid historical/peer P/E benchmarks opposes Valuation evidence.',
      neutralInterpretation:
          'P/E close to the available benchmarks is neutral.',
      recommendationImpact:
          'P/E is one input inside the single Valuation family and is not a standalone recommendation vote or fair-value target.',
      limitations:
          'Earnings can be cyclical, distorted or temporarily depressed. A lower P/E can be justified by weaker growth, quality or risk. Financial companies and REITs require specialized valuation handling.',
    ),
    InvestorMetricKind.priceToFreeCashFlowRelative: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Compares market capitalization with positive free cash flow and then compares that multiple with historical/peer medians.',
      calculation:
          'Divides market capitalization by positive free cash flow. The resulting multiple is compared with each valid point-in-time own-history and peer benchmark.',
      whyItMatters:
          'Price/FCF relates equity value to cash generated after operating and capital-investment needs.',
      supportiveInterpretation:
          'A meaningful discount to valid Price/FCF benchmarks supports Valuation evidence.',
      opposingInterpretation:
          'A meaningful premium to valid Price/FCF benchmarks opposes Valuation evidence.',
      neutralInterpretation: 'Price/FCF close to benchmarks is neutral.',
      recommendationImpact:
          'Price/FCF contributes only inside the single Valuation family.',
      limitations:
          'Free cash flow can be temporarily distorted by working-capital or capital-expenditure cycles. Non-positive FCF makes the multiple unavailable.',
    ),
    InvestorMetricKind
        .enterpriseValueToOperatingProfitRelative: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Compares enterprise value with positive operating profit and then compares that multiple with historical/peer medians.',
      calculation:
          'Estimates operating profit from revenue multiplied by operating margin, divides enterprise value by positive operating profit, and compares the multiple with valid point-in-time benchmarks.',
      whyItMatters:
          'Enterprise-value multiples help compare the value of the whole operating business while incorporating capital structure more directly than equity-only multiples.',
      supportiveInterpretation:
          'A meaningful discount to valid EV/Operating Profit benchmarks supports Valuation evidence.',
      opposingInterpretation:
          'A meaningful premium to valid EV/Operating Profit benchmarks opposes Valuation evidence.',
      neutralInterpretation:
          'EV/Operating Profit close to benchmarks is neutral.',
      recommendationImpact:
          'EV/Operating Profit is de-duplicated with P/E and Price/FCF inside the single Valuation family.',
      limitations:
          'Operating profit can be cyclical and accounting-sensitive. Non-positive operating profit invalidates the multiple. Banks, insurers and REITs require specialized valuation methods.',
    ),
    InvestorMetricKind.revenueEstimateRevision: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures how analyst consensus revenue for one matching future fiscal period changed across historical estimate vintages.',
      calculation:
          'Compares the latest revenue estimate with available 30-day and 90-day historical vintages for the same target period. The 90-day change receives 60% of the metric signal and the 30-day change 40% when both exist.',
      whyItMatters:
          'Upward revenue revisions can indicate improving expectations for future business activity; downward revisions can indicate weakening expectations.',
      supportiveInterpretation:
          'Material upward like-for-like revenue revisions support the Revisions family.',
      opposingInterpretation:
          'Material downward like-for-like revenue revisions oppose the Revisions family.',
      neutralInterpretation:
          'Small or conflicting revenue revisions are neutral.',
      recommendationImpact:
          'Revenue revisions contribute inside the single Revisions family and cannot become an independent vote.',
      limitations:
          'Analyst coverage can be sparse or wrong. Different fiscal target periods must never be compared as though they were revisions. Batch 5 normalization is provisional.',
    ),
    InvestorMetricKind.dilutedEpsEstimateRevision: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures how analyst consensus diluted EPS for one matching future fiscal period changed across historical estimate vintages.',
      calculation:
          'Compares latest EPS consensus with available 30-day and 90-day like-for-like historical vintages. Near-zero baselines are withheld because percentage revisions would be unstable.',
      whyItMatters:
          'EPS revisions can summarize changes in analysts’ expectations for future per-share profitability.',
      supportiveInterpretation:
          'Material upward EPS revisions support the Revisions family.',
      opposingInterpretation:
          'Material downward EPS revisions oppose the Revisions family.',
      neutralInterpretation: 'Small or conflicting EPS revisions are neutral.',
      recommendationImpact:
          'EPS revisions are de-duplicated with revenue and FCF revisions inside one Revisions family.',
      limitations:
          'EPS estimates are sensitive to accounting, tax, share count and one-off assumptions. Consensus can herd and can be revised after price has already moved.',
    ),
    InvestorMetricKind.freeCashFlowEstimateRevision: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures how analyst consensus free cash flow for one matching future fiscal period changed across historical estimate vintages.',
      calculation:
          'Compares latest FCF consensus with available 30-day and 90-day like-for-like vintages. Near-zero baselines are withheld.',
      whyItMatters:
          'Forward cash-generation revisions can change the company’s expected capacity to reinvest, repay debt or return capital.',
      supportiveInterpretation:
          'Material upward FCF revisions support the Revisions family.',
      opposingInterpretation:
          'Material downward FCF revisions oppose the Revisions family.',
      neutralInterpretation: 'Small or conflicting FCF revisions are neutral.',
      recommendationImpact:
          'FCF revisions contribute only inside the single Revisions family.',
      limitations:
          'FCF forecasts can be volatile because of working capital and capital spending assumptions, and provider history must preserve genuine historical vintages.',
    ),
    InvestorMetricKind.returnOnInvestedCapitalPersistence: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures whether reported ROIC remained positive and avoided severe erosion across the available annual history.',
      calculation:
          'Combines the share of positive annual ROIC observations with a penalty when the latest ROIC has eroded materially from the first observation.',
      whyItMatters:
          'Persistent returns on invested capital are more compatible with durable economics than returns that repeatedly disappear or collapse.',
      supportiveInterpretation:
          'Consistently positive ROIC with limited erosion supports observed durability.',
      opposingInterpretation:
          'Repeated negative ROIC or severe erosion opposes observed durability.',
      neutralInterpretation: 'Mixed persistence is neutral.',
      recommendationImpact:
          'ROIC Persistence contributes inside Competitive Durability, which is explicitly correlated with Profitability & Quality in Batch 5 and cannot yet satisfy independent core breadth.',
      limitations:
          'Positive ROIC does not prove an economic moat because Batch 5 does not compare ROIC with cost of capital or identify a structural competitive-advantage mechanism.',
    ),
    InvestorMetricKind.operatingMarginPersistence: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures whether operating profitability stayed positive and avoided severe erosion across multiple reported years.',
      calculation:
          'Combines the share of positive operating-margin observations with a penalty for material erosion from the first to latest observation.',
      whyItMatters:
          'Operating economics that persist through time are more durable than economics that disappear rapidly.',
      supportiveInterpretation:
          'Consistently positive operating margins with limited erosion support observed durability.',
      opposingInterpretation:
          'Repeated negative margins or severe erosion oppose observed durability.',
      neutralInterpretation: 'Mixed margin persistence is neutral.',
      recommendationImpact:
          'Operating Margin Persistence is one proxy inside Competitive Durability and is overlap-discounted because Profitability & Quality uses related raw data.',
      limitations:
          'This does not identify pricing power, switching costs, brand value or cost advantage, and normal margins vary by business model.',
    ),
    InvestorMetricKind.freeCashFlowPersistence: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures whether free cash flow remained positive and resilient across the available annual history.',
      calculation:
          'Combines the share of positive FCF observations with a penalty for erosion from the historical peak to the latest observation.',
      whyItMatters:
          'Persistent cash generation can make a long-term business thesis more resilient.',
      supportiveInterpretation:
          'Repeated positive FCF with limited erosion supports observed durability.',
      opposingInterpretation:
          'Repeated negative FCF or severe erosion from peak cash generation opposes observed durability.',
      neutralInterpretation: 'Mixed FCF persistence is neutral.',
      recommendationImpact:
          'FCF Persistence contributes inside Competitive Durability and is not an independent vote.',
      limitations:
          'Working-capital and capital-expenditure cycles can make FCF volatile. This proxy does not prove a structural moat and overlaps with other quality evidence.',
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
