# TradePilot AI — v0.12.0 Investor Strategy Brain

Status: Release acceptance complete — v0.12.0 Investor Strategy Brain
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
- **Batch 7** — Ownership/Positioning + zero-vote Market Expectations helper ✅
- **Batch 8** — Investor recommendation policy + attribution ✅
- **Batch 9** — Investor Historical Setup Validation ✅
- **Batch 10** — Investor UI activation ✅
- **Batch 11** — v0.12.0 release acceptance ✅

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

## Batch 7 — Ownership & Positioning + zero-vote Market Expectations

Implemented and validated on 2026-09-04.

Batch 7 adds a point-in-time-safe Investor Ownership & Positioning context family and a zero-vote Market Expectations presentation helper while keeping Investor recommendation generation and UI activation unavailable.

Ownership & Positioning implementation:

- Uses the existing vendor-neutral `OwnershipPositioningProvider`.
- Production provider requirements are strengthened:
  - filing-based holdings must preserve publication lag;
  - 13F-style quarter-end observations cannot be treated as known before publication;
  - short-interest data must use published aggregate position snapshots rather than daily short-sale volume;
  - raw insider net-share totals are not directionally safe without transaction-level classification.
- Added deterministic synthetic development fixtures for:
  - institutional ownership percentage;
  - institutional holder count;
  - short interest as percentage of float;
  - raw insider net shares.
- All synthetic fixtures preserve separate `observedAt` and `availableAt` timestamps.

Institutional Ownership Trend:

- Requires at least three published observations.
- Scores the multi-period **change** in institutional ownership percentage.
- The absolute institutional ownership level is not assigned bullish/bearish direction.
- Reliability is reduced as the underlying observation becomes stale.
- 13F-style publication lag remains visible in the point-in-time metadata and explainability.

Institutional Holder Breadth:

- Requires at least three positive published holder-count observations.
- Scores the percentage change in institutional-holder count.
- Holder breadth remains in the same `ownershipPositioning` family and cannot become a separate independent vote.
- Holder count does not imply position size, conviction or investment motive.

Short Interest Trend:

- Requires at least three published aggregate short-interest observations.
- Rising short interest is opposing context; falling short interest is supportive context.
- The **absolute short-interest level is not directionally scored**.
- Short interest is explicitly distinguished from daily short-sale volume.
- High short interest is not universally treated as bearish because hedging, positioning structure and squeeze risk can change interpretation.

Insider Transaction Context:

- Raw `insiderNetShares` remains non-directional in Batch 7.
- Batch 7 assigns zero signed score because raw net shares cannot distinguish:
  - open-market purchases/sales;
  - grants;
  - option exercises;
  - tax withholding;
  - gifts;
  - other transaction mechanics.
- Transaction-code-aware Form 4-style data is required before insider activity may receive directional interpretation.

Ownership-family role boundaries:

- `EvidenceFamily.ownershipPositioning` remains contextual.
- Ownership & Positioning cannot satisfy core-fundamental breadth.
- Ownership & Positioning cannot create an Investor BUY/SELL.
- Exact maximum contextual direction influence remains deferred to Batch 8.
- Publication age/staleness directly reduces reliability.

Market Expectations helper:

- Added `InvestorMarketExpectationsService`.
- This is **not** an evidence provider.
- Permanent invariants:
  - zero evidence votes;
  - zero direction points;
  - zero confidence points.
- Requires:
  - an available Valuation family; and
  - at least two available business families from Growth, Profitability & Quality and Revisions.
- It summarizes already-counted evidence into:
  - Expectations look conservative;
  - Expectations look balanced;
  - Expectations look demanding;
  - Expectations look very demanding;
  - Not enough data.
- The helper reconstructs signed family strength from already-counted family results and compares business support with valuation pressure.
- Ownership & Positioning may be displayed as contextual narrative but **does not alter the Market Expectations classification**.
- Market Expectations is not:
  - a fair-value model;
  - a DCF;
  - a price target;
  - a market-implied forecast;
  - a probability of future return.
- Its deterministic pressure bands are presentation heuristics and must never be reused as hidden recommendation weights.

Explainability:

- Added complete per-input explainability for:
  - Institutional Ownership Trend;
  - Institutional Holder Breadth;
  - Short Interest Trend;
  - Insider Transaction Context.
- Added complete helper-level explainability for Market Expectations.
- The distinction between evidence direction, contextual narrative and zero-vote presentation remains explicit.

Architecture invariants:

- Global `EvidenceKind` remains unchanged.
- Investor `StrategyAnalysisPolicy` remains planned.
- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable.
- No Investor recommendation or UI activation occurs in Batch 7.
- Development ownership/positioning inputs remain explicitly synthetic.
- Competitive Durability remains excluded from actionable core breadth pending Batch 8 overlap resolution.
- Market/macro context from Batch 6 remains contextual-only and VIX remains non-directional.

Batch 7 validation:

- Flutter analyzer: clean.
- Investor suite: 73 passing tests.
- Recommendation subsystem suite: 528 passing tests.
- Full automated suite: 602 passing tests.
- `git diff --check`: clean.
- No visual acceptance was required because Investor remains unavailable in the UI.

## Batch 8 — Investor Recommendation Policy + Attribution

Implemented and validated on 2026-09-04.

Batch 8 introduces the dedicated Investor recommendation backend while preserving the shared family-level consensus and attribution architecture.

### Frozen actionable core policy

The six breadth-eligible core families are:

1. Growth
2. Profitability & Quality
3. Financial Strength
4. Valuation
5. Revisions
6. Capital Allocation & Dilution

Actionable BUY/SELL requires:
- at least **4 of 6** breadth-eligible core families;
- core coverage of at least **2/3**;
- **Valuation available**;
- absolute direction score **>= 40**;
- confidence **>= 65**;
- no material core-fundamental conflict.

Strong BUY/SELL requires:
- absolute direction score **>= 70**;
- confidence **>= 80**;
- the same breadth and Valuation gates.

BUY and SELL use symmetric thresholds.

Non-action behavior:
- absolute direction `<= 20` => HOLD / No Clear Direction;
- core conflict `>= 0.50` => HOLD / No Clear Direction;
- insufficient direction/confidence => WAIT / Wait for Confirmation;
- insufficient breadth or missing Valuation => WAIT with typed coverage/breadth reasons.

### Competitive Durability overlap resolution for v0.12

Competitive Durability remains visible analysis, but its current proxy reuses ROIC, operating-margin and FCF inputs already represented in Profitability & Quality.

Therefore in v0.12 Batch 8:
- recommendation direction weight = `0`;
- confidence weight = `0`;
- breadth credit = `0`.

It cannot double-count Quality. Future non-zero weight requires genuinely independent durability inputs.

### Context cap

Directional context families are:
- Market Context;
- Ownership & Positioning.

Their **collective absolute direction-attribution share is capped at 20%** of the active post-de-duplication directional basis.

Context:
- cannot satisfy core breadth;
- cannot create BUY/SELL without core action gates;
- cannot dominate recommendation attribution;
- remains secondary to the company/business thesis.

### Confidence and attribution

Batch 8 confidence is derived from breadth-eligible core fundamentals only.

- Market Context confidence share = `0`.
- Ownership & Positioning confidence share = `0`.
- Competitive Durability confidence share = `0`.
- Market-implied volatility remains zero-direction and receives `0` confidence-adjustment points in Batch 8.
- No unvalidated VIX penalty is invented.

Direction attribution remains separate from confidence attribution.

The Investor backend preserves:
- family-capped direction influence;
- family direction shares reconciling to 100% when direction exists;
- provider direction impact reconciling to family impact;
- signed supportive/opposing influence;
- core-only confidence attribution;
- contextual direction only after the 20% cap.

Market Expectations remains:
- zero evidence votes;
- zero direction points;
- zero confidence points.

### Dedicated backend boundary

Batch 8 does **not** activate Investor through the generic `RecommendationEngine`.

The generic engine uses total independent-family count for action breadth, which would allow contextual families to satisfy an Investor fundamental gate incorrectly.

Instead `InvestorRecommendationEngine`:
- calculates fundamental breadth separately;
- preserves missing core families in the coverage denominator;
- applies the context cap before shared consensus;
- excludes zero-weight Competitive Durability;
- reuses the shared `ConsensusEngine`;
- merges contextual direction attribution with core-only confidence attribution;
- emits the shared `Recommendation` and `ScoringResult` models.

### Activation boundary

The dedicated Investor recommendation backend is implemented and validated, but:
- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable;
- Investor `StrategyAnalysisPolicy` remains `planned`;
- generic Investor orchestration remains guarded;
- Investor UI activation remains off.

Batch 9 adds Investor Historical Setup Validation before UI activation.

### Batch 8 validation

- Flutter analyzer: clean.
- Investor suite: **87 passing tests**.
- Recommendation subsystem suite: **542 passing tests**.
- Full automated suite: **616 passing tests**.
- `git diff --check`: clean.
- No visual acceptance required because Investor UI remains inactive.

## Batch 9 — Investor Historical Setup Validation

Implemented and validated on 2026-09-05.

Batch 9 adds Investor-specific point-in-time Historical Setup Validation while preserving the permanent rule that historical evidence is **confidence-only**.

### Investor-specific historical contract

Investor Historical Validation does not reuse the Trader/Swing candle fingerprint.

Instead each historical Investor case stores:

- symbol;
- historical setup timestamp;
- timestamp when the full historical recommendation fingerprint was actually knowable;
- signed scores for the six breadth-eligible core Investor families;
- historical recommendation direction/confidence;
- core-family count;
- mature 6-month, 12-month and 24-month forward outcomes;
- stock return and benchmark return for each mature horizon;
- explicit synthetic/source labeling.

A historical setup is rejected if its complete recommendation fingerprint became available **after** the setup timestamp.

Forward outcomes are usable only after the relevant horizon has fully matured by the current analysis date.

### Historical matching basis

Similarity uses only the six breadth-eligible core Investor families:

1. Growth
2. Profitability & Quality
3. Financial Strength
4. Valuation
5. Revisions
6. Capital Allocation & Dilution

Historical validation therefore cannot gain similarity credit from:

- Market Context;
- Ownership & Positioning;
- Market Expectations;
- Competitive Durability's overlapping proxy;
- other contextual helpers.

The current fingerprint must satisfy the same minimum core breadth as the recommendation policy and must include Valuation.

### Frozen matching safeguards

- Minimum similarity: **0.75**.
- Minimum de-overlapped matched cases: **8**.
- Minimum same-stock control cases: **12**.
- Minimum spacing between retained matched setups: **90 calendar days**.
- Near-duplicate historical setups inside the 90-day window are de-overlapped by retaining the higher-similarity case.
- Historical cases must be from the same symbol.
- Current/future cases are excluded.
- Look-ahead setup fingerprints are rejected.
- Neutral current Investor direction receives zero historical confidence impact.

### 6m / 12m / 24m horizon model

Investor historical outcomes are evaluated at:

- **6 months** — 25% policy weight;
- **12 months** — 50% policy weight;
- **24 months** — 25% policy weight.

Rules:

- 12-month evidence is mandatory.
- At least two mature usable horizons are required.
- If one non-mandatory horizon is unavailable, remaining horizon weights are renormalized.
- No horizon receives its own ±8 confidence allowance.
- All usable horizons collapse into **one combined historical-confidence overlay**.

### Same-stock baseline and benchmark-relative outcomes

Each mature horizon compares similar historical setups with the stock's broader same-direction historical baseline.

Two follow-through dimensions are measured:

1. Absolute directional follow-through.
2. Benchmark-relative directional follow-through.

The historical score therefore asks whether similar setups historically performed better or worse than that stock usually did under broader same-direction Investor setups, both absolutely and relative to the benchmark.

This prevents a generally strong bull market from being mistaken for setup-specific historical edge.

### Confidence-only boundary

Permanent invariants:

- historical direction impact = `0`;
- historical core-breadth impact = `0`;
- historical evidence votes = `0`;
- historical provider/family direction attribution = unchanged;
- historical contextual direction share = unchanged.

The existing shared `HistoricalConfidenceAdjuster` remains the only confidence-application mechanism.

The combined 6m/12m/24m result is bounded to:

**-8 to +8 final-confidence points maximum.**

Historical validation remains a separately labeled `historicalValidation` confidence modifier and is never reassigned to evidence-family/provider confidence attribution.

### Explainability

Investor Historical Validation has a complete confidence/risk-only explainability contract describing:

- what is matched;
- point-in-time reconstruction;
- horizon maturity;
- 6m/12m/24m weighting;
- same-stock baseline;
- benchmark-relative follow-through;
- de-overlapping;
- confidence-only role;
- ±8 cap;
- important limitations.

Historical similarity is explicitly **not** presented as a probability of profit, causal proof, fair value, or guaranteed forward return.

### Synthetic fixture correction during validation

The `IVOPPOSE` synthetic historical fixture initially produced approximately the same aligned outcome rate as its control baseline, correctly resulting in a `mixed` verdict.

The fixture was corrected so the intentionally opposing matched population has materially weaker follow-through than its control baseline.

This was a **test-data calibration only**:

- no production similarity threshold changed;
- no horizon weighting changed;
- no confidence cap changed;
- no historical scoring rule changed;
- no recommendation threshold changed.

### Integration with Investor recommendation backend

`InvestorRecommendationEngine.applyHistoricalValidation()`:

- applies the shared bounded historical confidence modifier;
- reclassifies recommendation state only when adjusted confidence crosses an existing Investor confidence threshold;
- preserves direction score;
- preserves direction attribution;
- preserves core-family count and coverage;
- preserves required-family status;
- preserves contextual direction share;
- attaches the shared `HistoricalSetupValidation` model to the recommendation.

### Activation boundary after Batch 9

Investor recommendation backend + historical validation are implemented and validated, but:

- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable;
- Investor `StrategyAnalysisPolicy` remains `planned`;
- generic Investor orchestration remains guarded;
- Investor UI activation remains off.

The next implementation step is **Batch 10 — Investor UI activation**.

### Batch 9 validation

- Flutter analyzer: clean.
- Investor suite: **101 passing tests**.
- Recommendation subsystem suite: **556 passing tests**.
- Full automated suite: **630 passing tests**.
- `git diff --check`: clean.
- No visual acceptance required because Investor UI remains inactive.

## Batch 10 — Investor UI Activation

Implemented, automated-test validated and visually accepted on 2026-09-05.

Batch 10 activates Investor in the real dashboard while preserving the dedicated v0.12 Investor backend and all previously frozen scoring, attribution and point-in-time rules.

### Dedicated activation path

Investor is selectable from Strategy Summary through its dedicated `InvestorAnalysisService` / `InvestorRecommendationEngine` path.

Batch 10 does **not** route Investor through the generic Trader/Swing recommendation engine.

Permanent integration boundary after Batch 10:

- `RecommendationStrategyPolicy.forStrategy(Investor)` remains unavailable;
- generic Investor `StrategyAnalysisPolicy` remains `planned`;
- Trader/Swing `EvidenceKind` orchestration remains unchanged;
- Strategy Summary can expose Investor availability through an explicit dedicated-backend availability signal;
- cached Trader, Swing and Investor recommendation states remain independent.

This keeps Investor's fundamental-family breadth and context-cap semantics from leaking into the generic short-horizon orchestration path.

### Investor analysis orchestration

The new Investor application service:

1. loads point-in-time fundamentals;
2. loads point-in-time analyst estimate vintages;
3. loads valuation context;
4. loads macro context;
5. loads stock-specific macro sensitivity history;
6. loads Ownership & Positioning;
7. builds one point-in-time-safe Investor snapshot;
8. evaluates the nine validated Investor evidence providers;
9. creates the dedicated Investor recommendation;
10. builds the zero-vote Market Expectations helper;
11. runs Investor Historical Setup Validation;
12. applies the shared bounded historical-confidence modifier.

An unsafe point-in-time snapshot is rejected rather than silently analyzed.

### Development-data boundary

The current application wiring uses the existing synthetic Investor providers.

The UI explicitly displays:

**Synthetic development data**

and explains that the displayed fundamentals, estimates, macro inputs, ownership data and historical examples are not live production company data.

Batch 10 therefore validates orchestration and presentation only. It does not claim that production Investor data vendors are connected.

### Investor dashboard order

The visually accepted Investor flow is:

1. Strategy Summary
2. Investor Analysis Context
3. Investor Recommendation
4. Investor Recommendation Insight
5. Business Strength
6. Valuation & Expectations
7. Global Market Context
8. Ownership & Positioning
9. Investor Evidence
10. Investor Risk Context
11. Investor Historical Setup Validation

The Investor dashboard does not present a short candle interval or `0 candles` as the long-term decision basis.

Investor selection also does not repurpose the shared price chart into a fake fundamental timeframe.

### Investor Analysis Context

The dedicated context card exposes human-readable values for:

- months-to-years analysis horizon;
- available core-fundamental breadth;
- point-in-time safety;
- explicit data mode;
- 6m / 12m / 24m historical-validation windows.

Each visible value has its own info affordance.

### Investor Recommendation

The dedicated Investor Recommendation card exposes:

- recommendation state;
- confidence;
- signed Investor direction score;
- core coverage;
- mandatory Valuation gate.

It intentionally avoids Trader/Swing wording such as primary candle count.

Confidence remains explicitly **not a probability of profit**.

### Recommendation Insight and attribution

The existing shared Recommendation Insight card is reused because its validated model already separates:

- Signal Strength / direction;
- Confidence;
- Signal Alignment;
- direction attribution;
- confidence attribution.

For Investor, Historical Validation is suppressed inside this shared card and presented later as its own dedicated Investor section so the UI order remains clear.

No Batch 10 UI code creates new recommendation weights.

### Business Strength

The Business Strength card exposes:

- Growth;
- Profitability & Quality;
- Financial Strength;
- Revisions;
- Capital Allocation;
- Competitive Durability.

Competitive Durability remains visible but is explicitly labeled as **0 recommendation weight in v0.12** because the current durability proxy overlaps Profitability & Quality.

Batch 10 does not change that Batch 8 de-duplication decision.

### Valuation & Expectations

The card exposes Valuation separately from the Market Expectations presentation helper.

Market Expectations remains a permanent zero-vote helper:

- zero evidence votes;
- zero direction points;
- zero confidence points.

Its UI explains that it summarizes already-counted business/valuation evidence and is not a DCF, fair-value target, market-implied forecast or probability.

### Global Market Context

Macro/global context remains secondary.

The UI preserves the frozen rule that Market Context + Ownership & Positioning may collectively receive no more than **20% of Investor direction attribution**.

Context cannot satisfy core-fundamental breadth and contributes zero Investor confidence share in v0.12.

### Ownership & Positioning

Ownership & Positioning remains contextual.

The UI preserves the distinction between:

- institutional ownership trend;
- institutional holder breadth;
- published short-interest trend;
- insider transaction context.

Raw insider net shares are not presented as directionally valid without transaction-code-aware production data.

### Investor Risk Context

Batch 10 intentionally does **not** reuse the generic placeholder RiskCard as though it were a production Investor Risk Engine.

Instead the dedicated Investor Risk Context card exposes validated constraints such as:

- actual contextual direction share;
- core-fundamental conflict;
- Historical Validation confidence impact;
- market-implied volatility context when available;
- explicit `Risk Engine Status: Not implemented`.

The card states that it is not position sizing, stop-loss or portfolio-risk advice.

### Investor Historical Setup Validation UI

Historical Validation is presented as the final dedicated Investor section.

The card exposes:

- historical verdict;
- confidence impact;
- matched setups;
- average similarity;
- mature 6m / 12m / 24m horizon details;
- absolute edge versus same-stock baseline;
- benchmark-relative edge;
- reliability.

The UI preserves the permanent confidence-only boundary:

- zero direction impact;
- zero core-breadth impact;
- one combined ±8 maximum confidence overlay.

Historical similarity is explicitly not presented as a probability of profit.

### Explainability acceptance

Investor-facing analytical values use visible info affordances.

The accepted dialogs explain, as applicable:

- what the value is;
- how it is calculated;
- supportive / opposing / neutral interpretation;
- why it matters;
- direction vs confidence/risk role;
- bounded impact;
- limitations.

This includes Growth, Valuation, Market Expectations, macro context, Ownership & Positioning, historical validation and Investor Risk Context.

### Automated validation

Final Batch 10 validation:

- Flutter analyzer: clean.
- Investor suite: **107 passing tests**.
- Dashboard orchestration suite: **3 passing tests**.
- Recommendation subsystem suite: **563 passing tests**.
- Full automated suite: **637 passing tests**.
- `git diff --check`: clean.

Two UI tests initially used an overly broad `textContaining('Synthetic development data')` finder. The UI legitimately contains both the synthetic-data warning and Data Mode value, so the tests were corrected to target the warning text specifically. This was a **test-selector correction only**; no production behavior changed.

### Visual acceptance

Chrome visual acceptance completed on 2026-09-05.

Accepted checks included:

- Investor selectable from Strategy Summary;
- complete Investor card order;
- visible synthetic-data warning;
- no misleading `0 candles` Investor decision basis;
- readable per-value info dialogs;
- separate direction and confidence attribution;
- zero-vote Market Expectations presentation;
- confidence-only Historical Validation presentation;
- no material clipping/overflow observed;
- Trader → Swing → Investor strategy switching preserves strategy-specific results.

### Release boundary after Batch 10

Batch 10 activates Investor UI, but **v0.12.0 release acceptance is not yet complete**.

Batch 10 does not:

- bump package/release version;
- change the visible version footer from the current release baseline;
- create the `v0.12.0` tag;
- declare production Investor data providers live;
- claim that a production Investor Risk Engine exists.

The next and final v0.12 implementation step is:

**Batch 11 — v0.12.0 release acceptance.**

## Batch 11 — v0.12.0 Release Acceptance

Release acceptance completed on 2026-09-05.

Batch 11 is a release-only checkpoint. It does not introduce new Investor scoring, thresholds, evidence, attribution, historical-validation behavior or recommendation semantics.

### Release metadata

- Flutter package version: `0.12.0+1`.
- Visible application version: `Version 0.12.0`.
- Designated release tag: `v0.12.0`.
- Release validator: `./tools/validate-release-0.12.sh`.

### Final automated release gate

The v0.12.0 release validator completed successfully.

Final validated results:

- Dart formatting check: passed with no required formatting changes.
- Flutter analyzer: clean.
- Investor suite: **107 passing tests**.
- Dashboard strategy-orchestration suite: **3 passing tests**.
- Full dashboard widget acceptance test: **1 passing test**.
- Recommendation subsystem suite: **563 passing tests**.
- Full automated suite: **637 passing tests**.
- `flutter build web`: passed and produced `build/web`.
- `git diff --check`: clean.

### Visual acceptance

The Investor dashboard received manual Chrome visual acceptance in Batch 10 on 2026-09-05.

That acceptance covered:

- Investor selectable from Strategy Summary;
- complete Investor section order;
- explicit synthetic development-data warning;
- no misleading `0 candles` long-term decision basis;
- readable per-value info/explainability dialogs;
- separate direction and confidence attribution;
- zero-vote Market Expectations presentation;
- confidence-only Historical Validation presentation;
- no material clipping/overflow;
- strategy switching between Trader, Swing and Investor.

Batch 11 changes only release metadata and the reusable release validator. The visible `Version 0.12.0` footer is also protected by the passing full-dashboard widget test, so no new analytical/UI behavior was introduced after visual acceptance.

### v0.12.0 acceptance result

The v0.12.0 Investor Strategy Brain acceptance criteria are satisfied for the current development-data architecture:

- Investor is a genuine months-to-years strategy rather than Swing on slower candles.
- Independent long-term economic families are implemented.
- Actionable Investor BUY/SELL requires sufficient independent core-fundamental breadth and Valuation.
- Market/Macro context is measurable and stock-sensitivity-aware rather than vague opinion.
- Market Expectations remains transparent and zero-vote.
- Ownership/Positioning remains contextual and latency-aware.
- invalid universal formulas are withheld where business-model normalization is not supported.
- point-in-time guards protect historical reconstruction.
- BUY/SELL parity and directional-family behavior are regression-tested.
- direction attribution and confidence attribution remain mathematically separate.
- every visible Investor analytical value has an individual explainability path.
- Trader and Swing remain regression-protected.
- synthetic Investor data remains explicitly labeled.

### Production-readiness boundary

`v0.12.0` is an accepted **development milestone**, not a claim of live-data production readiness.

Still intentionally outstanding:

- authoritative production Investor fundamental provider integration;
- licensed/authoritative analyst-estimate history;
- production peer classifications/distributions;
- production ownership/positioning feeds;
- real historical Investor setup database and out-of-sample calibration;
- production Investor Risk Engine;
- AI Analyst / Mentor;
- final commercial UI/design pass.

The dedicated Investor backend remains separate from the generic Trader/Swing `RecommendationStrategyPolicy` and `StrategyAnalysisPolicy` path. That separation is intentional and must not be removed merely to make the architecture look uniform.

### Release completion

With this checkpoint committed, pushed and tagged `v0.12.0`, the Investor Strategy Brain release is complete.

The next product milestone is:

**v1.0.0 — validated multi-strategy milestone with Trader, Swing and Investor implemented, followed by production-data hardening and broader release-readiness work.**

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
