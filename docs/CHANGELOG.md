# TradePilot AI

Document ID:
TP-010

Document:
Project Changelog

Version:
1.2

Status:
Approved

Last Updated:
2026-08-31

Owner:
TradePilot AI

Related Documents:
- TP-001 Master Specification
- TP-009 Project Roadmap

---

## v0.12.0 — Investor Strategy Brain

Status

Implementation Active — Batch 9 Investor Historical Setup Validation Validated

Date

2026-09-01

Summary

Opened v0.12.0 as the dedicated months-to-years Investor Strategy Brain.

Batch 0 defines independent fundamental evidence families, core-fundamental breadth, Global Market & Macro Context, stock-specific sensitivity, Ownership & Positioning, point-in-time historical discipline, sector/business-model normalization, and a zero-vote `Market Expectations` synthesis.

No production Investor recommendation behavior changes in Batch 0.

Detailed scope:

`docs/INVESTOR_STRATEGY_BRAIN_V0_12.md`

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

---

## v0.11.0 — Swing Strategy Brain

Status

Release Acceptance Complete — Batches 1-10 Validated

Date

2026-08-23

Summary

Opened v0.11.0 as the dedicated Swing Strategy Brain release.

This checkpoint defines architecture, evidence applicability, explainability, attribution and acceptance requirements before production implementation begins.

No production recommendation behavior has changed in this checkpoint.

### Implementation Progress — 2026-08-29

Batches 1-8 are implemented and regression-validated.

Completed:
- Strategy-aware evidence policy and collection gates.
- Swing timeframe/context orchestration.
- Swing-calibrated evidence families and contextual capabilities.
- Swing Event Risk confidence-only enforcement.
- Swing Historical Setup Validation calibration and horizon integrity.
- Swing-specific recommendation decision policy.
- Swing recommendation backend activation.
- Strategy-aware controller/service recommendation execution.
- Independent Trader and Swing dashboard recommendation-state orchestration.
- Attribution integrity and mathematical reconciliation.
- User-facing attribution and confidence explainability.
- Current analysis-window VWAP remains excluded from Swing.
- Trader regression protection and strategy-readiness invariants.

Batch 8 attribution boundaries:
- Direction attribution is calculated from effective post-family-cap current-case contribution.
- Active family direction shares reconcile to 100% whenever directional evidence exists.
- Signed provider direction impacts reconcile to their capped family contribution.
- Provider internal absolute shares are diagnostic only and are not shown as percentages of the recommendation.
- User-facing provider detail uses signed direction points.
- Evidence confidence remains separate from directional attribution.
- Confidence-modifier sources are explicitly classified.
- Evidence-quality adjustments remain internal confidence inputs.
- Event Risk is displayed separately as a confidence-only point adjustment with zero direction and maximum -12 points.
- Historical Setup Validation is displayed separately as a confidence-only point adjustment with zero direction and maximum ±8 points.
- Final confidence reconciles from evidence-derived confidence plus allowed external confidence adjustments.
- Attribution metrics use reusable MetricExplainability definitions and individual info controls.
- Confidence is not presented as a probability of profit.
- No Batch 8 change modifies scoring weights, evidence direction, family caps or Swing recommendation thresholds.

Functional validation at Batch 8 implementation completion:
- Flutter analyzer: clean.
- Recommendation subsystem suite: 439 passing tests.
- Full automated suite: 512 passing tests.

### Batch 9A — Swing UI Activation

Implemented:

- Activated Swing in the visible Strategy Summary while keeping Investor unavailable.
- Added an implementation-ready pre-analysis state: `Ready to analyze`.
- Made Strategy Summary safe when an active strategy has no confidence result yet.
- Connected Dashboard presentation to `DashboardController` strategy-specific recommendation caches instead of constructing a Trader-only local recommendation list.
- Selecting Swing now runs the existing Swing backend and presents Swing-specific Analysis Context, Recommendation, Recommendation Insight, Evidence and Risk.
- Preserved independent Trader and Swing cached recommendation states.
- Added top-level UI regression coverage for Trader -> Swing activation.
- No scoring weights, evidence direction, family caps, attribution math, Event Risk behavior or Historical Setup Validation behavior changed.

Batch 9A validation:

- Focused Strategy Summary/dashboard/top-level UI gate: 8 passing tests.
- Recommendation subsystem suite: 441 passing tests.
- Dashboard subsystem suite: 5 passing tests.
- Flutter analyzer: clean.
- `git diff --check`: clean.
- Full automated suite: 514 passing tests.

### Batch 9B — Swing Decision Helpers

Implemented:

- Added a Swing-only Decision Helper card between Recommendation Insight and Evidence.
- Added human-readable `Entry Quality`, `Price Stretch` and `Structure Watch` outputs.
- Derived Price Stretch from existing Swing Price Extension evidence.
- Derived Structure Watch from existing Swing Support & Resistance evidence.
- Derived Entry Quality as a presentation summary rather than a proprietary numeric score.
- Added individual reusable explainability/info paths for every helper.
- Kept the helper layer strictly downstream of the recommendation engine.
- Decision Helpers add zero evidence votes, zero direction points and zero confidence points.
- Trader remains unchanged and Investor remains Coming Soon.
- No scoring weights, evidence direction, recommendation thresholds, family caps, attribution math, Event Risk or Historical Setup Validation behavior changed.

Batch 9B validation:

- Focused Decision Helper / top-level UI gate: 9 passing tests.
- Recommendation subsystem suite: 449 passing tests.
- Flutter analyzer: clean.
- `git diff --check`: clean.
- Full automated suite: 522 passing tests.
- Manual Chrome visual acceptance: passed on 2026-08-31.

### Batch 10 — v0.11.0 Release Acceptance

Release acceptance completed on 2026-08-31.

Batch 10A release-state coverage:
- Audited the production Swing orchestration path with deterministic development data rather than lowering recommendation thresholds.
- Corrected synthetic Event Risk coverage so Swing mock data can represent both relevant-event and no-relevant-event states.
- Added an explicit development-only `BULL` fixture to exercise the complete Swing BUY path through the real dashboard/recommendation orchestration.
- Added a full-dashboard release-action regression fixture.
- Synthetic fixtures do not bypass recommendation gates and do not alter production scoring weights, family caps, direction thresholds, confidence thresholds, Event Risk policy or Historical Validation policy.

Batch 10B recommendation-state clarity:
- Internal `WAIT` remains the non-actionable developing-signal state, but the UI now presents it as `Wait for Confirmation`.
- Internal `HOLD` remains the neutral/conflicted state, but the UI now presents it as `No Clear Direction` so it is not confused with portfolio-position advice.
- Recommendation outcomes now expose typed decision reasons rather than requiring UI text parsing.
- WAIT explanations are dynamically derived from the actual failed gate(s), including insufficient evidence coverage, directional strength, confidence and independent-family breadth.
- HOLD explanations distinguish neutral evidence from material bullish/bearish conflict.
- No Batch 10B change alters scoring, thresholds, evidence direction, attribution, family caps or recommendation outcomes.

Release metadata:
- Flutter package version: `0.11.0+1`.
- Visible application version: `Version 0.11.0`.
- Designated release tag: `v0.11.0`.

Final release gate:
- Flutter analyzer: clean.
- Focused release/UI gate: 22 passing tests.
- Recommendation subsystem suite: 455 passing tests.
- Full automated suite: 529 passing tests.
- `flutter build web`: passed (`build/web` produced successfully).
- `git diff --check`: clean.
- Manual Chrome visual acceptance: passed, including Swing BUY presentation and the Batch 10B non-action wording/explanations.

Next planned release work:

**v0.12.0 — Investor Strategy Brain after the accepted v0.11.0 checkpoint is committed, pushed and tagged.**

### Release Boundary

- v0.11.0 — Swing Strategy Brain.
- v0.12.0 — Investor Strategy Brain.
- v1.0.0 — validated Trader + Swing + Investor multi-strategy milestone.

Swing is explicitly separated from Investor rather than implementing both engines inside one v1.0 release.

### Core Architecture Decision

Swing is not Trader logic running on slower candles.

Before Swing becomes active, every existing:

- Evidence provider.
- Evidence family.
- Context input.
- Confidence modifier.
- Historical capability.
- Recommendation helper.
- Decision helper.

must receive an explicit Swing applicability and calibration decision.

v0.11.0 will introduce a strategy-aware policy layer supporting:

- Provider applicability.
- Strategy-specific parameters.
- Lookbacks.
- Thresholds.
- Reliability and weight.
- Semantic role.
- Direction behavior.
- Confidence behavior.
- Risk / entry-quality behavior.
- Evidence-family constraints.

### Swing Timeframe Policy

Approved default hierarchy:

- 1D primary.
- 1W confirmation.
- 1M regime.

Approved alternate hierarchy:

- 4H primary.
- 1D confirmation.
- 1W regime.

### Approved Evidence Audit Decisions

#### Trend
- Candle Trend — reuse with Swing calibration.
- EMA Structure — reuse with Swing calibration.
- Multi-Timeframe Trend — core Swing evidence.

#### Momentum
- RSI — retain with trend/regime-aware Swing interpretation.
- RSI overbought/oversold thresholds must not automatically create SELL/BUY direction.
- MACD Momentum — retain with Swing calibration.

#### Participation
- Relative Volume — conditional reuse.
- 1D Swing may use daily relative-volume history.
- 4H Swing must not fabricate same-time-of-day normalization.
- Volume Confirmation — retain with Swing calibration and volatility-aware move significance.

#### Price Structure
- Current analysis-window VWAP Position — excluded from initial Swing scoring.
- Support & Resistance — core Swing evidence with confirmation-aware semantics.
- Proximity to support/resistance alone is not confirmed direction.

#### Volatility / Entry Quality
- Price Extension — primarily entry-quality/confidence/risk context.
- Extension must not automatically claim that the opposite trend has begun.

#### Market Context
- Market & Sector Context / Relative Strength — core Swing evidence.
- Market Breadth — retained inside the Market Context family.

#### Sentiment
- News Sentiment — retained with Swing-specific freshness and materiality policy.

### Confidence / Context Decisions

#### Event Risk
- Confidence/risk-only.
- Cannot create Buy/Sell direction.
- Cannot create a positive confidence bonus.
- Maximum 12-point confidence penalty.
- Swing requires a strategy-specific event relevance horizon.

#### Stock DNA
- Core contextual capability.
- Must become strategy-aware.
- Must not create standalone Buy/Sell direction.

#### Historical Setup Validation
- Confidence-only.
- Strategy/timeframe-specific.
- Swing outcomes must use a Swing-appropriate forward horizon.
- Trader and Swing outcomes must not be pooled as equivalent observations.
- Maximum ±8 final-confidence points.

### Human-Readable UI Rule

Every Swing:

- Card.
- Evidence item.
- Metric.
- Context value.
- Decision helper.
- Historical statistic.
- Risk/confidence value.
- Recommendation component.

must be understandable in plain human language.

Main UI should present human meaning first and technical detail second.

Every individual analytical input/value must have its own visible info/explainability path.

A card-level general explanation does not replace individual metric explainability.

### Explainability Rule

Every individual Swing input must explain, where applicable:

1. What it means.
2. How it is calculated.
3. Why it matters for Swing.
4. Supportive interpretation.
5. Opposing interpretation.
6. Neutral interpretation.
7. Direction impact.
8. Confidence impact.
9. Risk / entry-quality impact.
10. Evidence-family and de-duplication implications.
11. Limitations.

### Recommendation Attribution Rule

Direction influence and confidence contribution remain separate.

User-facing directional percentages must represent actual current-case effective influence after:

- Strategy-specific weighting.
- Reliability.
- Contextual adjustment.
- Signal magnitude.
- Evidence-family aggregation.
- Family caps.
- Correlation de-duplication.

The active directional basis must reconcile to 100%.

Provider-level attribution must reconcile to the capped family contribution.

Configured static weights must not be presented as though they were actual current-case percentages.

Supportive and opposing contributions must remain identifiable.

Confidence-only modifiers are not normalized into the directional 100%.

Examples:

- Event Risk: explicit negative confidence-point adjustment.
- Historical Setup Validation: explicit bounded ± confidence-point adjustment.

### Data-Honesty Rule

Synthetic/mock data remains explicitly identified.

Swing thresholds and weights must not be described as statistically optimized from synthetic historical outcomes.

Unavailable or neutral evidence is preferable to fabricated information.

### Detailed Contract

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

### Next Implementation Step

After the documentation checkpoint is committed, begin:

**Batch 1 — Strategy-aware analysis/evidence policy foundation**

Swing must not be activated in the UI before the strategy-policy architecture and recommendation orchestration are validated.

---

## v0.10.1 — Explainability & Bidirectional Audit

Status

Completed

Date

2026-08-23

Summary

Converted TradePilot AI's permanent explainability rules from documentation and UI conventions into reusable, typed and automatically tested architecture.

### Added
- Reusable `MetricExplainability` domain contract.
- Explicit semantic roles for directional/evaluative, confidence/risk-only and context/configuration metrics.
- Central explainability catalog covering every production `EvidenceKind`.
- Individual explainability paths for all seven Trader Analysis Context metrics.
- Shared explainability content and dialog rendering.
- Historical Setup Validation explainability covering supportive, opposing and neutral outcomes.
- Automated explainability-completeness and semantic-role tests.

### Changed
- Production evidence explanations now expose recommendation impact and limitations in addition to existing description and calculation information.
- Historical Setup Validation now uses the reusable explainability contract.
- Historical Setup Validation explicitly explains its same-stock comparable-condition baseline.
- Event Risk is explicitly classified as confidence/risk-only.
- Sentiment is now documented as an implemented evidence family.

### Invariants / Safeguards
- Directional/evaluative metrics require supportive and opposing interpretations where mathematically meaningful.
- Context/configuration metrics cannot manufacture artificial directional meaning.
- Event Risk cannot create Buy/Sell direction.
- Event Risk cannot create a positive confidence bonus.
- Event Risk is hard-capped at a 12-point confidence penalty.
- Historical Setup Validation cannot alter recommendation direction.
- Historical Setup Validation preserves evidence-derived confidence.
- Historical Setup Validation is hard-capped to ±8 final-confidence points.
- Evidence-family de-duplication remains intact.
- Direction influence and confidence contribution remain separate concepts.
- BUY/SELL analytical parity remains protected.

### Validation
- `flutter analyze`: no issues.
- Full Flutter test suite: 263 tests passed.
- Provider regression suite: 47 tests passed.
- All six documented v0.10.1 visual acceptance checks passed.

---

## v0.10.0 — Market, Event & News Context

- Added Market Breadth as a de-duplicated Market Context provider.
- Added reliability-weighted News Sentiment as a separate Sentiment family.
- Added scheduled earnings/macro Event Risk as a confidence-only modifier capped at 12 points.
- Expanded Trader Analysis Context with breadth, event and news rows plus explainability.
- Added replaceable external-context provider architecture with explicit synthetic-development labeling.

# Purpose

This document records all significant changes made throughout the lifecycle of the TradePilot AI project.

The changelog provides a chronological history of the project's evolution.

Minor formatting changes, comments, or internal refactoring that do not affect functionality may be omitted.

---

# Changelog Format

Each release shall contain:

- Version
- Status
- Date
- Summary
- Added
- Changed
- Fixed
- Removed (if applicable)

---


# Version 0.9.0

Status

Development / Validation

Date

2026-08-20

Summary

Historical Setup Validation adds a bounded, strategy-aware historical analog layer on top of the deterministic recommendation engine.

### Added

- Historical setup fingerprints built from de-duplicated evidence families, Stock DNA, volatility regime, Market Environment, Relative Strength and selected strategy interval.
- Similarity matcher with cross-symbol analogs and a modest same-symbol statistical-weight preference.
- Similar-case count, Kish effective sample size, match quality, follow-through rate, context-matched stock baseline rate, Historical Difference, median forward move, favorable excursion and adverse excursion.
- Strategy/timeframe-specific forward outcome windows.
- `Historical Setup Check` inside Recommendation Insight with expandable analog details and limitations.
- Mock historical setup provider explicitly labeled as synthetic development data.
- Historical validation unit, widget, integration and timeframe tests.

### Refined — 2026-08-21

- Stock Profile is now a hard eligibility gate for historical setup analogs.
- Replaced the unconditional/control return list with structured same-stock comparison observations.
- The comparison baseline now requires the same strategy, primary interval, Stock Profile, volatility regime and Market Environment while deliberately ignoring today's specific evidence pattern.
- Historical validation requires at least 12 context-matched same-stock baseline observations before it may affect confidence.
- Reworked Historical Setup Check wording around Similar historical setups, stock behavior under comparable conditions, Historical Difference (`+/-N% points`) and Confidence effect.
- Removed `control` terminology from the normal user-facing historical UI.

### Changed

- Confidence now distinguishes evidence-derived confidence from final confidence after external validation.
- Historical validation may adjust confidence by at most ±8 points and cannot change direction by itself.
- Positive historical credit requires matched outcomes to beat both 50% directional follow-through and the context-matched stock baseline.
- Evidence/provider confidence attribution reconciles to evidence-derived confidence; historical adjustment is shown separately.
- Dashboard version marker advanced to 0.9.

### Safety / statistical discipline

- Historical setup fingerprints contain setup-time information only; future outcome data is evaluation-only.
- Historical validation is not an independent evidence family and therefore cannot double-count the current indicators.
- Current synthetic outcomes validate architecture/UI only and must not be interpreted as real strategy performance.

---


# Version 0.8.0

Status

Development / Validation

Date

2026-08-18

Summary

Advanced Trader evidence with explicit family de-duplication and clearer grouped explainability.

### Added

- EMA Structure in the Trend evidence group.
- MACD Momentum in the Momentum evidence group.
- Volume Confirmation in the Participation evidence group.
- VWAP Position and Support & Resistance in the new Price Structure evidence group.
- ATR-normalized Price Extension in the Volatility evidence group.
- Shared technical-indicator math utilities for EMA, ATR and analysis-window VWAP.
- Context-aware weighting rules for all new evidence kinds.
- Expandable evidence-family UI so many provider-level signals do not overwhelm the default dashboard.
- Provider, utility, context and integration tests for the v0.8 brain.
- Selectable Trader Primary Analysis Interval: 1m, 5m, 15m, 30m and 1h.
- Strategy-specific timeframe policy with future Swing and Investor defaults.
- Deterministic recommendation attribution for every independent evidence group.
- Provider-level direction and confidence attribution that respects family de-duplication.
- Exact confidence build-up from evidence-strength baseline through coverage, alignment and reliability adjustments.

### Changed

- Trader evidence can now contain eleven provider-level signals while the Consensus Engine sees at most six independent evidence groups.
- Dashboard version label updated to 0.8.
- Recommendation Insight recognizes Price Structure as a user-facing evidence group.
- Analysis Context now owns the analysis-interval selector; Market Status no longer presents strategy analysis settings.
- Trader confirmation/backdrop intervals adapt automatically to the selected primary interval.
- Price History range remains independent from recommendation analysis.
- Recommendation Insight now shows family-level direction influence and confidence share, with provider-level details expandable.
- Direction attribution and confidence attribution are explicitly separated so percentages are not misleading.

### Deliberately deferred

- ADX and Bollinger Bands until historical validation proves incremental value beyond existing trend/volatility measures.
- True session VWAP until real market data provides authoritative intraday session boundaries.

---

# Version 0.7.0

Status

Development / Validation

Date

2026-08-17

Summary

Strategy-aware multi-timeframe and market/sector context intelligence.

### Added

- Trader timeframe hierarchy: 5m Primary, 1h Confirmation, 1D Regime.
- MultiTimeframeProfile and adaptive trend-alignment service.
- Multi-Timeframe Trend evidence inside the existing Trend family.
- MarketContextProfile with stock-vs-market, stock-vs-sector, sector-vs-market and broad-market context.
- Market & Sector Context as an independent evidence family.
- Mock security-to-sector resolver and deterministic SPY/XLK/XLC/XLY benchmark behavior.
- Trader Analysis Context card with Timeframe Alignment, Market Environment and Relative Strength.
- Tests for timeframe alignment, market relative strength, family de-duplication, context loading and user-facing explainability.

### Changed

- Recommendation startup now loads Stock DNA and strategy analysis context in parallel before running consensus.
- The recommendation report can include five providers: Candle Trend, RSI, Relative Volume, Multi-Timeframe Trend and Market & Sector Context.
- Mock stock behavior is timeframe-specific so development scenarios can exercise aligned, mixed and opposed higher-timeframe conditions.
- Strategy Summary now precedes Analysis Context so strategy selection establishes the context for all detailed analysis below it.
- Trader timeframe labels now describe both role and candle interval: Short-term trend (5-minute candles), Near-term trend (1-hour candles), and Daily backdrop (1-day candles).

### Guarded

- Multi-timeframe trend remains in the Trend family so extra timeframes cannot inflate independent-family confidence.
- Missing context data falls back cleanly instead of fabricating benchmark information.
- Mock sector mappings are explicitly development-only and must be replaced by authoritative metadata with real market data.

---

# Version 0.6.0

Status

Development / Validation

Date

2026-08-17

Summary

Historical Context / Stock DNA foundation.

### Added

- One-year daily historical Stock DNA baseline.
- HistoricalStockProfile and deterministic historical profile service.
- Rolling normalized ATR% and annualized realized-volatility baselines.
- Current volatility percentile versus the stock's own history.
- 20D/60D average daily volume, volume trend and volume variability.
- 20D/60D historical trend efficiency.
- Structural Steady / Balanced / Volatile Stock Type.
- Calm / Normal / Elevated current volatility regime relative to the same stock's history.
- Stock DNA UI with plain-English explanation and technical detail on demand.
- Tests for historical stock classification, volatility regime, volume behavior, contextual weights and Stock DNA UI.

### Changed

- Stock behavior profiling now prefers long-term daily history instead of classifying the stock only from the 48-candle Trader snapshot.
- RSI, Candle Trend and Relative Volume context weights can now respond to historical Stock DNA.
- Deterministic mock historical data now has symbol-specific volatility and volume characteristics so steady and volatile paths can be tested.
- The recommendation brain uses a fixed one-year history request independent of the visual Market History range.

### Fixed / guarded

- Historical-data failure falls back to the short-term profile instead of blocking recommendation generation.
- Same-time-of-day RVOL is intentionally not simulated from daily candles; it remains deferred until true matching intraday data is available.

---

# Version 0.5.0

Status

Development / Validation

Date

2026-08-16

Summary

Strategy-aware family consensus architecture.

### Added

- EvidenceFamily classification.
- Consensus Engine with family-level influence caps.
- Direction score separate from confidence.
- Bullish and bearish support metrics.
- Agreement, conflict and family coverage metrics.
- Strategy-aware Recommendation Insight card.
- Strategy selection context for Recommendation, Evidence and Risk.
- Tests for correlated-evidence de-duplication and strategy-aware UI.

### Changed

- Simplified the consensus presentation from six technical summary boxes to three user-facing concepts: Signal Strength, Confidence and Signal Alignment.
- Moved agreement, conflict, coverage, reliability and evidence-group internals behind `How was this calculated?`.
- Added plain-English `Why this confidence?` explanation and info dialogs for the three primary concepts.
- Recommendation card is now explicitly strategy-labeled.
- Strategy Summary is the master selector for detailed analysis.
- ScoringEngine now delegates to the family Consensus Engine.
- Evidence cards expose their evidence family.

### Fixed

- Removed ambiguity over whether the generic Recommendation card represented Trader, Swing or Investor.

---

# Version 0.4.0

Status

Completed

Date

2026-08-16

Summary

Context-aware recommendation brain foundation.

### Added

- Relative Volume evidence.
- Stock Behavior profile.
- ATR%-based volatility context.
- Contextual evidence weighting.
- Market History range support and chart integration.

---

# Version 0.1.0

Status

Completed

Date

2026-07-06

Summary

Project foundation established.

### Added

- Flutter project initialized.
- Backend project structure created.
- Git repository initialized.
- GitHub repository created.
- Master Specification created.
- Feature Specification created.
- AI Specification created.
- UI/UX Specification created.
- Architecture Specification created.
- Documentation Standard created.
- Development Guidelines created.
- Security Specification created.
- Legal Specification created.
- Project Roadmap created.
- Initial TradePilot AI application shell.
- Flutter feature-based architecture.
- Git development workflow.

### Changed

None.

### Fixed

None.

### Removed

Flutter default counter application.

---

# Future Releases

Future versions shall continue using the following format.

Example

Version X.Y.Z

Status

Completed

Date

YYYY-MM-DD

Summary

...

Added

...

Changed

...

Fixed

...

Removed

...

---

# Version Numbering

TradePilot AI follows Semantic Versioning.

Major

Breaking changes.

Example

2.0.0

---

Minor

New functionality.

Example

1.3.0

---

Patch

Bug fixes.

Example

1.3.2

---

# Release Status

Possible values:

Development

Testing

Release Candidate

Completed

Deprecated

---

# Release Principles

Every released version shall:

- Build successfully.
- Pass required testing.
- Be committed to Git.
- Be synchronized with GitHub.
- Have updated documentation.

---

# Milestone Mapping

Each major milestone should correspond to at least one released version.

Example

Milestone 1

↓

Version 0.1

Milestone 2

↓

Version 0.2

...

Public MVP

↓

Version 1.0

---

# Revision History

| Version | Date | Author | Description |
|----------|------------|----------------|---------------------------|
| 1.0 | 2026-07-06 | TradePilot AI | Initial version |

---

# Approval

Status:
Approved

Approved By:
Project Founder

Architecture Owner:
TradePilot AI

---

# Change Control

This document follows the TradePilot AI Documentation Standard.

Changes require:

1. Approval.

2. Version update.

3. Git commit.
### v0.8 UX refinement — collapsible primary dashboard cards
- Moved Watchlist to the top of the dashboard so symbol selection happens before analysis.
- Made Watchlist collapsible; its collapsed header keeps the selected symbol visible.
- Made Market Status collapsible; its collapsed header keeps the current symbol and price visible.
- Added a reusable `CollapsibleDashboardCard` shared widget and widget coverage.

### v0.9 weighted historical scoring refinement
- Replaced the previous 40/40/20 historical outcome blend with an explicit four-dimension weighting policy: difference vs context-matched stock baseline 40%, directional follow-through 20%, normalized outcome magnitude 20%, and excursion quality 20%.
- Added favorable-versus-adverse excursion quality so two setups with the same win rate can receive different historical quality scores when their risk paths differ.
- Converted historical reliability into a separate weakest-link gate using effective sample depth and match quality rather than treating reliability as another outcome vote.
- Preserved the anti-drift rule: historical validation cannot add confidence unless matched setups beat both the 50/50 directional baseline and the context-matched stock baseline.
- Kept historical confidence impact capped at ±8 points and prohibited historical validation from changing recommendation direction by itself.
- Added user-facing historical scoring-weight and reliability breakdowns inside Historical Setup Check details.
