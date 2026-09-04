# TradePilot AI — v0.12.0 Investor Strategy Brain

Status: Implementation active — Batch 6 Global Market & Macro Context + Stock Sensitivity Profile validated
Release: v0.12.0
Baseline: v0.11.0 — Swing Strategy Brain
Baseline commit: 665fd8f0be86c8ce62cb2d37e1d2acbda910bd69
Baseline tag: v0.11.0
Scope opened: 2026-09-01

## Purpose

Investor is TradePilot AI's months-to-years strategy.

Investor is not Swing running on weekly/monthly candles. The company/business thesis must dominate, while market, macro, positioning and long-term technical context refine timing, confidence and risk.

The Investor brain must answer two different questions:

1. How strong, healthy, durable and attractively valued is the business?
2. What are observable markets, macro conditions and investor positioning currently implying about that business and its future expectations?

## Research basis

Batch 0 reviewed current public methodologies and data sources:

- Seeking Alpha separates Value, Growth, Profitability, Momentum and EPS Revisions and uses sector-relative comparison.
- Morningstar separates fair value, uncertainty and durable competitive advantage/economic moat.
- TipRanks separately exposes analyst, hedge-fund/institutional, insider, news, technical and fundamental factors.
- Fama/French research separates market, value, profitability and investment effects across regions.
- SEC EDGAR exposes structured XBRL company facts.
- SEC Form 13F exposes institutional holdings, but the data is quarterly and filings may lag quarter end by up to 45 days.
- Federal Reserve/FRED data can support rates and financial-conditions regimes.
- Cboe VIX measures expected market volatility and is explicitly non-directional.

TradePilot AI will not copy proprietary formulas. These sources only inform architecture and measurable input categories.

## Permanent Investor rules

### Fundamentals must dominate

An actionable Investor BUY/SELL requires sufficient independent core-fundamental coverage.

Technical, macro, sentiment or positioning evidence cannot satisfy the action-breadth gate by themselves.

If core fundamentals are missing, return a typed non-action state.

### Do not use one giant Fundamentals family

The current `EvidenceFamily.fundamentals` placeholder is too coarse.

Investor requires independent families because Growth, Profitability, Financial Strength, Valuation and Revisions answer economically different questions. Collapsing them into one family would incorrectly de-duplicate them under the existing family cap.

### Proposed core families

1. **Growth**
   - revenue growth
   - EPS growth where meaningful
   - free-cash-flow/per-share growth
   - 3Y/5Y CAGR
   - acceleration/deceleration

2. **Profitability & Quality**
   - gross/operating/FCF margins
   - ROIC/capital efficiency
   - margin stability
   - cash conversion / earnings quality

3. **Financial Strength**
   - leverage
   - net debt
   - interest coverage
   - liquidity
   - debt trend/refinancing risk
   - business-model-specific rules for banks, insurers, REITs, etc.

4. **Valuation**
   - P/E where meaningful
   - EV/EBITDA / EV/EBIT
   - price/free cash flow / FCF yield
   - valuation versus own history
   - valuation versus relevant peers
   - no falsely precise single DCF point in initial v0.12

5. **Revisions**
   - EPS/revenue revision breadth
   - magnitude and direction
   - 30D/90D changes
   - estimate dispersion
   - requires authoritative point-in-time estimate data

6. **Competitive Durability**
   - ROIC persistence
   - margin persistence
   - market-share/pricing-power proxies only when reliable
   - no invented opaque moat score

7. **Capital Allocation & Dilution**
   - share-count change
   - SBC burden
   - buybacks net of issuance
   - dividend sustainability
   - debt-funded distributions
   - reinvestment efficiency

### Context / timing layers

**Long-Term Market Context**
- global/regional market regime
- sector/industry regime
- stock relative strength versus market/sector
- long-horizon breadth where reliable

**Long-Term Technical Context**
- weekly/monthly structural trend
- secondary timing role
- cannot replace the business thesis

**Ownership & Positioning**
- institutional ownership trend
- institutional-holder breadth/concentration
- insider activity where authoritative
- short interest where authoritative and horizon-compatible
- 13F latency must be visible in reliability/explainability

**Persistent Information / Sentiment**
- only material, durable thesis changes
- low/capped Investor influence
- short-lived headline tone must not drive long-term recommendations

## Global Market & Macro Context

This is a first-class Investor context layer, but it is not a single "global sentiment" score.

Candidate measurable inputs:

- policy-rate regime
- long-term yields
- yield-curve shape
- real-rate regime where available
- financial-conditions indices
- credit/risk conditions where reliable
- inflation trend
- broad/regional equity regime
- market-implied volatility, explicitly non-directional
- currency regime
- commodity regime when the company has measurable exposure

### Stock Sensitivity Profile

Prefer stock-specific exposure over universal macro assumptions.

Candidate methodology:
- weekly observations
- multi-year rolling history
- minimum sample gate
- market + sector sensitivity first
- macro/factor exposure only when statistically stable
- reliability penalty for unstable coefficients, low explanatory power or collinearity
- unavailable is better than false precision

Potential exposed sensitivities:
- market
- sector
- rates
- currency
- commodity
- regional
- factor/style where useful

Global Macro Context may adjust:
- confidence
- valuation interpretation
- risk/timing
- capped direction only when stock-specific exposure is demonstrably measured

It cannot create Investor BUY/SELL by itself.

## Market Expectations & Positioning

The UI should help answer:

> Is the current market price/positioning demanding unusually strong execution, roughly matching current fundamentals, or pricing relatively conservative expectations?

Possible conclusions:
- Expectations look conservative
- Expectations look balanced
- Expectations look demanding
- Expectations look very demanding
- Not enough data

This is a **zero-vote presentation helper**.

It may summarize already-counted:
- Growth
- Quality
- Valuation
- Revisions
- Ownership/Positioning

It adds zero evidence votes, zero direction points and zero confidence points.

This prevents double counting.

## Direction / confidence / breadth

All v0.11 invariants remain:

- direction attribution uses actual effective post-family-cap influence
- active directional basis reconciles to 100%
- provider influence reconciles to family influence
- supportive/opposing influence remains visible
- confidence attribution remains separate
- confidence-only modifiers remain explicit point adjustments

Before production Investor scoring, freeze:
- core-fundamental family list
- minimum core-family breadth
- provider coverage requirement
- action direction threshold
- action confidence threshold
- conflict behavior
- maximum context/timing influence

## Sector and business-model normalization

Do not apply one universal ratio model to every company.

Examples:
- banks/insurers need financial-sector balance-sheet rules
- REITs need FFO/AFFO-style economics
- unprofitable growth companies need different valuation interpretation
- cyclicals need cycle-aware normalization
- capital-intensive firms require different reinvestment/cash-flow interpretation

Unsupported categories should be unavailable rather than misleading.

## Data-provider boundaries

Proposed replaceable interfaces:

- `FundamentalDataProvider`
- `AnalystEstimateProvider`
- `PeerClassificationProvider`
- `MacroContextProvider`
- `InvestorSensitivityDataProvider`
- `OwnershipPositioningProvider`
- `InvestorHistoricalDataProvider`

Initial U.S. authoritative candidate for reported fundamentals: SEC EDGAR XBRL/companyfacts.

Analyst revisions and many peer/positioning datasets may require licensed providers. Until selected, development data must remain clearly synthetic.

## Point-in-time historical discipline

Investor history must use information actually available on the historical setup date.

- SEC facts become usable at filing/publication time, not fiscal-period end.
- 13F holdings become usable at filing/publication time, not quarter end.
- analyst revisions require point-in-time historical estimate data.
- restatements must not silently create historical look-ahead.

Candidate Investor forward validation windows:
- 6 months
- 12 months
- 24 months

Historical Setup Validation remains confidence-only unless a future release explicitly proves and approves another role.

## Proposed UI order

1. Strategy Summary
2. Investor Analysis Context
3. Investor Recommendation
4. Investor Recommendation Insight
5. Business Strength
6. Valuation & Expectations
7. Global Market Context
8. Ownership & Positioning
9. Investor Evidence
10. Investor Risk
11. Historical Setup Validation

Every visible analytical value requires its own info/explainability path.

## Proposed implementation sequence

- **Batch 0** — research, scope, evidence audit
- **Batch 1** — Investor domain/family/provider-contract foundation ✅
- **Batch 2** — Growth + Profitability/Quality ✅
- **Batch 3** — Financial Strength + Capital Allocation ✅
- **Batch 4** — Valuation ✅
- **Batch 5** — Revisions + Competitive Durability ✅
- **Batch 6** — Global Market & Macro Context + Stock Sensitivity Profile ✅
- **Batch 7** — Ownership/Positioning + zero-vote Market Expectations helper
- **Batch 8** — Investor recommendation policy + attribution
- **Batch 9** — Investor Historical Setup Validation
- **Batch 10** — Investor UI activation
- **Batch 11** — v0.12.0 release acceptance

## Batch 1 — Investor Domain / Family Foundation

Implemented and validated on 2026-09-01.

Foundation changes:

- Expanded `EvidenceFamily` with independent Investor families:
  - Growth
  - Profitability & Quality
  - Financial Strength
  - Valuation
  - Revisions
  - Competitive Durability
  - Capital Allocation
  - Ownership & Positioning
- Retained the legacy `fundamentals` family only for compatibility/reserved use; it is not counted as Investor core-fundamental breadth.
- Added `InvestorEvidenceFamilyPolicy` with exactly seven core fundamental families and separate contextual families.
- Added vendor-neutral typed contracts for:
  - `FundamentalDataProvider`
  - `AnalystEstimateProvider`
  - `PeerClassificationProvider`
  - `MacroContextProvider`
  - `OwnershipPositioningProvider`
  - `InvestorHistoricalDataProvider`
- Added point-in-time metadata with separate `observedAt` and `availableAt` timestamps.
- Added explicit synthetic-data identification in Investor point-in-time snapshots.
- Added exhaustive human-readable presentation handling for all new families in shared evidence/consensus/attribution widgets.
- Kept `EvidenceKind` unchanged in Batch 1.
- Kept Investor `StrategyAnalysisPolicy` planned/deferred.
- Kept `RecommendationStrategyPolicy.forStrategy(Investor)` unavailable.
- Added no Investor evidence providers, scoring weights, thresholds, recommendation generation or UI activation.

Batch 1 validation:

- Flutter analyzer: clean.
- Investor foundation suite: 8 passing tests.
- Recommendation subsystem suite: 463 passing tests.
- Full automated suite: 537 passing tests.
- `git diff --check`: clean.
- No visual acceptance was required because Investor remains unavailable and Batch 1 does not activate new Investor UI behavior.

## Batch 2 — Growth + Profitability & Quality

Implemented and validated on 2026-09-01.

Batch 2 introduces the first real Investor analytical evidence while keeping Investor recommendation generation unavailable.

Implemented architecture:

- Added an Investor-specific evidence boundary that consumes point-in-time Investor data and emits the shared `EvidenceResult` shape.
- Added typed per-metric assessments with:
  - availability state;
  - supportive / opposing / neutral direction;
  - symmetric signed evaluative signal;
  - reliability;
  - current/baseline values;
  - complete individual explainability.
- Added a reusable Investor family aggregation helper so multiple related metrics become one de-duplicated family assessment rather than multiple independent votes.
- Kept global `EvidenceKind` unchanged. Batch 2 Investor definitions remain intentionally outside the current Trader/Swing strategy selector until Investor orchestration is ready.
- Kept `RecommendationStrategyPolicy.forStrategy(Investor)` unavailable and Investor `StrategyAnalysisPolicy` planned.

Growth family implementation:

- Revenue multi-year CAGR.
- Diluted EPS multi-year CAGR when positive endpoints make CAGR mathematically meaningful.
- Free Cash Flow multi-year CAGR when positive endpoints make CAGR mathematically meaningful.
- Revenue is required plus at least one additional valid growth measure.
- Non-positive CAGR endpoints are withheld rather than converted into misleading percentage growth.
- Revenue, EPS and FCF are combined into exactly one Growth-family evidence result.
- Batch 2 normalization is deterministic development policy and is not presented as historically optimized.

Profitability & Quality family implementation:

- Gross Margin Trend.
- Operating Margin Quality.
- Free Cash Flow Margin Quality.
- Return on Invested Capital Quality.
- Gross Margin is trajectory-first because absolute normal levels differ substantially by industry.
- Operating Margin, FCF Margin and ROIC combine trajectory with a bounded positive/negative economic level component centered on zero.
- No universal sector-specific “good margin” or “good ROIC” threshold is claimed in Batch 2.
- Peer/sector-relative profitability calibration remains deferred until reliable peer distributions are available.
- The four metrics combine into exactly one Profitability & Quality family evidence result.

Synthetic development fixtures:

- `IVBULL` — improving Growth and improving Profitability & Quality.
- `IVBEAR` — contracting Growth and deteriorating Profitability & Quality.
- `IVMIX` — positive Growth with deteriorating Profitability & Quality, proving independent economic-family disagreement is preserved.
- `IVFLAT` — approximately neutral Growth.
- All development fundamentals are explicitly marked synthetic and point-in-time metadata is preserved.

De-duplication / architecture proof:

- Three Growth metrics remain one Growth family.
- Four Profitability/Quality metrics remain one Profitability & Quality family.
- Feeding both family results into the existing `ConsensusEngine` produces exactly two independent families, not seven metric votes.
- No Trader/Swing production calculation file was changed by Batch 2.

Batch 2 validation:

- Flutter analyzer: clean.
- Investor suite: 18 passing tests.
- Recommendation subsystem suite: 473 passing tests.
- Full automated suite: 547 passing tests.
- `git diff --cached --check`: clean.
- Batch 2 code checkpoint before documentation: 10 new files, 1,255 insertions.
- No visual acceptance was required because Investor remains unavailable in the UI.

## Batch 3 — Financial Strength + Capital Allocation & Dilution

Implemented and validated on 2026-09-01.

Batch 3 adds two more independent Investor core-fundamental families while keeping Investor recommendation generation unavailable.

Financial Strength implementation:

- Net Debt / Free Cash Flow.
- Operating-profit Interest Coverage.
- Cash / Debt.
- The three measures are aggregated into exactly one Financial Strength family result.
- Net cash and strong debt-service capacity can support the family.
- Heavy net debt, weak coverage and low liquidity can oppose the family.
- The model is explicitly not a credit rating.
- Generic corporate leverage rules are withheld for identified banks, insurers and similar financial-sector structures because their balance sheets require specialized regulatory/accounting analysis.
- `unavailable` is preferred over applying invalid industrial-company leverage rules.

Capital Allocation & Dilution implementation:

- Net Share Count Change.
- Stock-Based Compensation Burden.
- Cash Return Funding.
- Net share-count change receives the greatest influence because it measures the actual shareholder dilution outcome after buybacks and issuance.
- Gross buyback spending cannot hide a rising share count.
- No dividend/buyback program is neutral rather than automatically negative.
- Cash returns comfortably funded within FCF receive only modest positive influence; larger payouts are not treated as automatically better.
- Materially over-funded distributions can oppose the family.
- The three measures are aggregated into exactly one Capital Allocation & Dilution family result.

Data-contract / synthetic-fixture extensions:

- Added positive cash-flow fields for `dividendsPaid` and `shareRepurchases`.
- Expanded the deterministic Investor mock fundamentals with cash, debt, interest expense, shares outstanding, SBC, dividends and repurchases.
- Existing `IVBULL`, `IVBEAR`, `IVMIX` and neutral/default fixtures now carry the additional balance-sheet and allocation data.
- All development inputs remain explicitly synthetic and preserve point-in-time availability metadata.

Architecture / de-duplication proof:

- Growth remains one family.
- Profitability & Quality remains one family.
- Financial Strength remains one family.
- Capital Allocation & Dilution remains one family.
- Feeding all four implemented core-family results into the existing `ConsensusEngine` produces exactly four independent families rather than treating each underlying metric as a separate vote.
- Global `EvidenceKind` remains unchanged.
- Investor `StrategyAnalysisPolicy` remains planned.
- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable.

Batch 3 validation:

- Flutter analyzer: clean.
- Investor suite: 27 passing tests.
- Recommendation subsystem suite: 482 passing tests.
- Full automated suite: 556 passing tests.
- `git diff --check`: clean.
- No visual acceptance was required because Investor remains unavailable in the UI.

## Batch 4 — Valuation

Implemented and validated on 2026-09-01.

Batch 4 adds the fifth independent Investor core-fundamental family while keeping Investor recommendation generation unavailable.

Valuation data architecture:

- Added a vendor-neutral `MarketValuationDataProvider`.
- Added point-in-time market valuation inputs separate from filing fundamentals.
- Added point-in-time valuation-reference metadata so historical/peer medians cannot silently use information that became available only later.
- Market valuation inputs are not stored as filing fundamentals.
- Added synthetic deterministic valuation fixtures for development/testing only.

Initial Valuation family:

- P/E versus own-history and/or peer median.
- Price / Free Cash Flow versus own-history and/or peer median.
- Enterprise Value / Operating Profit versus own-history and/or peer median.
- The three usable comparisons are aggregated into exactly one Valuation family result.

Permanent Batch 4 safeguards:

- No absolute rule such as “P/E below X is cheap.”
- A multiple becomes directional only relative to explicit valid own-history and/or peer benchmarks.
- Negative or zero earnings make P/E unavailable rather than artificially cheap.
- Negative or zero free cash flow makes Price/FCF unavailable.
- Negative or zero operating profit makes EV/Operating Profit unavailable.
- Relative multiple discounts/premiums are not presented as price-target upside/downside.
- No single fair-value price target or DCF point estimate is produced.
- Identified banks, insurers and REITs are withheld until specialized valuation rules exist.
- At least two usable relative multiples are required for an available Valuation family assessment.

Explainability / de-duplication:

- Every new valuation metric has complete individual explainability.
- P/E, Price/FCF and EV/Operating Profit remain inputs inside one Valuation family rather than becoming three independent votes.
- Growth, Profitability & Quality, Financial Strength, Capital Allocation & Dilution and Valuation now produce exactly five independent implemented core-family votes in the existing `ConsensusEngine`.
- Global `EvidenceKind` remains unchanged.
- Investor `StrategyAnalysisPolicy` remains planned.
- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable.

Batch 4 validation:

- Flutter analyzer: clean after the missing valuation-test import was corrected.
- Investor suite: 35 passing tests.
- Recommendation subsystem suite: 490 passing tests.
- Full automated suite: 564 passing tests.
- `git diff --check`: clean.
- No visual acceptance was required because Investor remains unavailable in the UI.

## Batch 5 — Revisions + Competitive Durability

Implemented and validated on 2026-09-01.

Batch 5 adds point-in-time analyst Revisions and an observed Competitive Durability proxy while keeping Investor recommendation generation unavailable.

Revisions implementation:

- Added target-period-aware `InvestorEstimatePoint` so historical estimate vintages identify the fiscal/forecast period they refer to.
- Historical revisions compare only like-for-like estimates for the same future target period.
- Comparing FY1 with FY2 is explicitly forbidden because it would create a false revision.
- Revenue Estimate Revision.
- Diluted EPS Estimate Revision.
- Free Cash Flow Estimate Revision.
- Available 90-day and 30-day windows are combined inside each forecast metric before Revenue/EPS/FCF are de-duplicated into one Revisions family.
- Current consensus cannot be silently backfilled into historical analysis.
- Near-zero estimate baselines are withheld when percentage revision math would be unstable.
- Revisions is an independent Investor core family, but Investor recommendations remain inactive.

Competitive Durability implementation:

- ROIC Persistence.
- Operating Margin Persistence.
- Free Cash Flow Persistence.
- Durability measures observed persistence/resilience of reported economics only.
- It does not claim to identify a structural economic moat.
- It does not infer network effects, switching costs, brand power, patents, cost advantage or efficient scale.
- It does not yet compare ROIC with cost of capital.
- The family receives an explicit reliability discount because its raw inputs overlap with Profitability & Quality.

Correlation / breadth safeguard:

- `CompetitiveDurability` has a separate evidence-family identity for explainability and future architecture.
- Batch 5 explicitly marks it as sharing inputs with Profitability & Quality.
- Competitive Durability is **not eligible to increase independent core breadth in Batch 5**.
- Batch 8 must define an explicit overlap/de-duplication/correlation policy before Competitive Durability can influence actionable Investor breadth or attribution.
- Revisions remains independently eligible because it is based on point-in-time forward estimate changes rather than the reported profitability inputs used by Profitability & Quality.

Architecture invariants:

- Global `EvidenceKind` remains unchanged.
- Investor `StrategyAnalysisPolicy` remains planned.
- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable.
- No Investor UI activation occurs in Batch 5.
- All development estimate/fundamental fixtures used here remain explicitly synthetic.

Batch 5 validation:

- Flutter analyzer: clean after the Batch 5 lint/nullability corrections.
- Investor suite: 46 passing tests.
- Recommendation subsystem suite: 501 passing tests.
- Full automated suite: 575 passing tests.
- `git diff --check`: clean.
- No visual acceptance was required because Investor remains unavailable in the UI.

## Batch 6 — Global Market & Macro Context + Stock Sensitivity Profile

Implemented and validated on 2026-09-04.

Batch 6 adds a point-in-time-safe Investor market/macro context layer based on measured stock-specific sensitivity rather than universal macro assumptions. Investor recommendation generation and UI activation remain unavailable.

Sensitivity architecture:

- Added a vendor-neutral `InvestorSensitivityDataProvider`.
- Added aligned weekly `InvestorSensitivityObservation` history carrying:
  - stock return;
  - broad-market change;
  - sector change;
  - long-term-yield change;
  - financial-conditions change;
  - U.S.-dollar change;
  - market-implied-volatility change;
  - point-in-time metadata.
- Factor **changes**, not unlike raw factor levels, are stored in the aligned sensitivity history.
- The current observation is excluded from fitting historical sensitivity and is used only after the historical relationship is established.
- Point-in-time safety applies to the complete sensitivity history, including synthetic development fixtures.

Directional sensitivity gates:

- Minimum 52 **prior** aligned weekly observations are required, plus one current observation.
- Minimum absolute full-sample stock/factor correlation: `0.35`.
- Both historical half-samples must maintain the same correlation sign.
- Minimum absolute half-sample correlation: `0.20`.
- The current factor move is standardized against prior factor-change history before contextual scoring.
- Highly collinear factors at absolute correlation `>= 0.75` cannot both survive as independent directional context inputs; the weaker stock-specific relationship is suppressed.
- Broad Market and Sector are modeled first, followed by Long-Term Yield, Financial Conditions and U.S. Dollar sensitivity.
- Weak, unstable, insufficient or collinear sensitivity becomes neutral/unavailable rather than generating false precision.

Role boundaries:

- All directional sensitivity remains inside `EvidenceFamily.marketContext`.
- Market/macro context cannot satisfy core-fundamental breadth.
- Market/macro context cannot create an Investor BUY/SELL.
- Exact maximum context/timing direction influence remains deferred to Batch 8.
- Market-implied volatility remains **confidence/risk-only** and contributes exactly zero direction points in Batch 6.
- Any future volatility confidence/risk effect must be explicitly capped and cannot create BUY/SELL direction.

Competitive Durability breadth enforcement:

- `CompetitiveDurability` remains a core business concept/family.
- Because Batch 5 durability reuses ROIC, operating-margin and FCF inputs that overlap with Profitability & Quality, it remains excluded from actionable breadth.
- Batch 6 now enforces that safeguard centrally through a separate breadth-eligible core-family set.
- `hasCoreFundamentalBreadth(...)` uses breadth-eligible core families, not every conceptual core family.
- Batch 8 must explicitly resolve the Competitive Durability overlap before it may count toward actionable breadth or recommendation attribution.

Explainability / regression correction:

- Added individual explainability for Broad Market Sensitivity, Sector Sensitivity, Long-Term Yield Sensitivity, Financial Conditions Sensitivity, U.S. Dollar Sensitivity and Market-Implied Volatility Context.
- The historical Batch 2 integrity test was narrowed to the seven metrics that actually existed in Batch 2. It still requires those original metrics to remain directional.
- Global Investor metric-catalog completeness remains enforced.
- The Batch 2 test no longer incorrectly requires future confidence/risk-only metrics such as Market-Implied Volatility Context to be directional.

Architecture invariants:

- Global `EvidenceKind` remains unchanged.
- Investor `StrategyAnalysisPolicy` remains planned.
- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable.
- No Investor recommendation or UI activation occurs in Batch 6.
- Development market/macro/sensitivity inputs remain explicitly synthetic.

Batch 6 validation:

- Flutter analyzer: clean.
- Investor suite: 58 passing tests.
- Recommendation subsystem suite: 513 passing tests.
- Full automated suite: 587 passing tests.
- `git diff --check`: clean.
- No visual acceptance was required because Investor remains unavailable in the UI.

## Acceptance criteria

v0.12.0 is not complete until:

- Investor is a genuine months-to-years strategy.
- Independent fundamental families replace the single generic Fundamentals concept.
- actionable Investor recommendations require core-fundamental breadth.
- Global Market/Macro Context uses observable data plus stock-specific sensitivity rather than vague opinion.
- Market Expectations is transparent and zero-vote.
- positioning data exposes latency and limitations.
- sector/business-model normalization prevents invalid universal ratios.
- point-in-time rules prevent historical look-ahead leakage.
- BUY/SELL parity is tested for every directional family.
- direction and confidence attribution remain mathematically separate.
- every visible Investor metric/value has its own explainability path.
- Trader and Swing remain regression-protected.
- mock/synthetic Investor data is always labeled.

## Initial non-goals

- opaque 0–100 Investor score
- AI-generated moat score without grounded deterministic inputs
- social-media sentiment as a core Investor family
- intraday order flow
- session VWAP
- short-horizon options positioning as a core Investor input
- falsely precise single DCF value
- live claims from mock data
- self-learning/reweighting before point-in-time out-of-sample validation

## Research sources

- Seeking Alpha Quant Ratings:
  https://help.seekingalpha.com/premium/what-are-quant-ratings-and-how-do-i-use-them
- Morningstar stock ratings:
  https://www.morningstar.com/help-center/stocks/morningstar-ratings-for-stocks
- TipRanks Smart Score:
  https://www.tipranks.com/news/labs/get-a-full-stock-analysis-with-tipranks-smart-score
- SEC EDGAR APIs:
  https://www.sec.gov/search-filings/edgar-application-programming-interfaces
- SEC Form 13F datasets:
  https://www.sec.gov/data-research/sec-markets-data/form-13f-data-sets
- SEC Form 13F FAQ:
  https://www.sec.gov/rules-regulations/staff-guidance/division-investment-management-frequently-asked-questions/frequently-asked-questions-about-form-13f
- Kenneth French developed-market five-factor description:
  https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/f-f_5developed.html
- Chicago Fed ANFCI via FRED:
  https://fred.stlouisfed.org/series/ANFCI
- Cboe VIX explanation:
  https://www.cboe.com/insights/posts/what-the-vix-and-vix-1-d-indices-attempt-to-measure-and-how-they-differ/

These sources inform architecture categories only. TradePilot AI must independently define and validate its formulas, thresholds, caps and provider contracts.
