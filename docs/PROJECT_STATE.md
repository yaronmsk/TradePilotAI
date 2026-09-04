# TradePilot AI Project State

**Document ID:** TP-012
**Version:** 2.0
**Status:** Active
**Last Updated:** 2026-08-31
**Primary Branch:** `develop`

---

## 1. Current Release Baseline

Previous tagged baseline release:

**v0.10.1 — Explainability & Bidirectional Audit**

Release commit:

`c53ad00 — docs: finalize v0.10.1 explainability release`

v0.10.1 is complete, tagged and synchronized with `origin/develop`.

Current release checkpoint:

**v0.11.0 — Swing Strategy Brain**

Status:

**Release acceptance complete — Batches 1–10 implemented and validated; designated release tag: `v0.11.0`.**

Detailed v0.11.0 evidence, capability and acceptance contract:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

v0.11.0 activates Swing as TradePilot AI's second real strategy.

Swing must not be implemented as Trader logic running on slower candles.

Before Swing is activated in the UI, every existing evidence provider, context input, confidence modifier, historical capability, recommendation helper and decision helper must receive an explicit Swing applicability and calibration decision.

Approved release sequence:

* v0.11.0 — Swing Strategy Brain.
* v0.12.0 — Investor Strategy Brain.
* v1.0.0 — validated multi-strategy milestone with Trader, Swing and Investor implemented.

---

## 2. Current Development Phase

**Brain-first feature development.**

The current focus is:

**v0.12.0 — Investor Strategy Brain**

Batch 8 Investor Recommendation Policy + Attribution implemented and validated.

Detailed v0.12 contract:

`docs/INVESTOR_STRATEGY_BRAIN_V0_12.md`

The current UI remains functional and intentionally provisional.

The first v0.11.0 production objective is not Swing UI activation.

The first production architecture must introduce a strategy-aware analysis/evidence policy capable of expressing genuine differences between Trader and Swing.

Approved implementation sequence begins with:

1. Strategy-aware evidence/applicability policy.
2. Swing timeframe/context orchestration.
3. Evidence-family-by-family Swing calibration.
4. Swing historical-validation horizon.
5. Swing recommendation orchestration and recommendation policy.
6. Attribution and explainability.
7. Human-readable Swing UI and decision helpers.
8. Full regression, visual acceptance, documentation and release.

Detailed evidence-by-evidence decisions are maintained in:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

No existing Trader evidence provider is automatically valid for Swing merely because it can consume slower candles.

---

## 3. Implemented Product Capabilities

### Market / Dashboard

* Persistent watchlist.
* Symbol-specific deterministic mock market behavior.
* Market Status with historical chart.
* Independent 1D / 5D / 1M / 3M / 1Y Price History ranges.
* Price History range remains independent from recommendation-analysis timeframe.
* Fixed one-year daily history feed for Stock DNA.
* Collapsible Watchlist and Market Status dashboard cards.
* Selected symbol remains visible when Watchlist is collapsed.
* Current symbol and price remain visible when Market Status is collapsed.

### Strategy Model

* Trader — implemented and active.
* Swing — v0.11.0 release acceptance complete; strategy-specific backend, visible activation, Decision Helpers and recommendation-state clarity are implemented and validated.
* Investor — v0.12.0 Batch 8 Investor Recommendation Policy + Attribution implemented and validated; dedicated backend recommendation generation exists, while generic strategy/UI activation remains unavailable.
* Strategy Summary is the master context selector for detailed analysis.
* Recommendation, Evidence, Context and Risk belong explicitly to the selected strategy.
* Trader Primary Analysis Interval is selectable:

  * 1m
  * 5m
  * 15m
  * 30m
  * 1h
* Confirmation and backdrop intervals adapt automatically.
* Price History range does not alter the strategy analysis interval.

---

## 4. Recommendation Brain

Implemented evidence includes:

### Trend

* Candle Trend.
* Multi-Timeframe Trend.
* EMA Structure.

### Momentum

* RSI.
* MACD Momentum.

### Participation

* Relative Volume.
* Volume Confirmation.

### Price Structure

* VWAP Position.
* Support & Resistance.

### Volatility

* ATR-normalized Price Extension.

### Market Context

* Market & Sector Context.
* Market Breadth.

### Sentiment

* News Sentiment.

The Consensus Engine operates at the evidence-family level rather than treating every indicator as an independent vote.

Correlated providers within the same evidence family are de-duplicated so they cannot create artificial confidence.

Direction and confidence remain separate concepts.

The recommendation model exposes:

* Bullish support.
* Bearish support.
* Agreement.
* Conflict.
* Provider coverage.
* Evidence-family coverage.
* Family-level direction influence.
* Family-level confidence contribution.
* Provider-level attribution behind expandable detail.
* Confidence build-up and external confidence modifiers.

---

## 5. Historical Context / Stock DNA

Implemented:

* Preferred one-year daily historical baseline.
* Short-snapshot fallback.
* Typical normalized daily ATR%.
* Current vs historical realized-volatility percentile.
* 20D and 60D average daily volume.
* Daily-volume variability.
* 20D/60D volume trend ratio.
* 20D/60D trend efficiency.
* Structural Stock Profile:

  * Steady
  * Balanced
  * Volatile
* Current Volatility Regime:

  * Calm
  * Normal
  * Elevated
* Stock-DNA-aware evidence weighting.
* User-facing Stock DNA card.
* Plain-English explanation with technical detail available on demand.

Structural stock behavior remains separate from the stock's current volatility regime.

---

## 6. Historical Setup Validation

v0.9 introduced bounded historical analog validation.

Implemented:

* Historical setup fingerprints.
* Evidence-family-aware matching.
* Stock DNA context.
* Volatility regime matching.
* Market Environment matching.
* Relative Strength context.
* Strategy/timeframe-specific matching.
* Cross-symbol analogs.
* Same-symbol statistical weighting preference.
* Similar-case count.
* Kish effective sample size.
* Match quality.
* Directional follow-through rate.
* Context-matched same-stock baseline.
* Historical Difference.
* Median forward move.
* Favorable excursion.
* Adverse excursion.
* Strategy/timeframe-specific forward outcome windows.

Stock Profile is a hard eligibility gate.

The comparison baseline requires matching:

* Strategy.
* Primary interval.
* Stock Profile.
* Volatility regime.
* Market Environment.

The comparison baseline deliberately ignores the current evidence pattern.

At least 12 context-matched same-stock baseline observations are required before historical validation may affect confidence.

Historical validation:

* Cannot independently change recommendation direction.
* Can modify confidence by at most ±8 points.
* Requires matched outcomes to beat both the 50% directional baseline and the context-matched stock baseline before positive confidence credit is permitted.
* Is shown separately from evidence-derived confidence.

Current historical outcomes remain synthetic development data and are not real strategy-performance evidence.

---

## 7. v0.10 External Context Intelligence

### Market Breadth

Market Breadth evaluates whether broad market participation supports the headline market move.

It belongs to the **Market Context** evidence family.

It is de-duplicated with Market & Sector Context.

Inputs include:

* Broad advancing participation.
* Medium-term participation.
* Sector participation.
* Volatility-regime pressure.

### Event Risk

Event Risk surfaces scheduled catalysts such as:

* Earnings.
* High-impact macro events.

Event Risk is a **confidence-only modifier**.

It:

* Cannot directly change recommendation direction.
* Is capped at a maximum 12-point confidence penalty.
* Appears separately in confidence attribution.

### News Sentiment

News Sentiment summarizes directional tone from recent company-specific news.

It belongs to the independent **Sentiment** evidence family.

Reliability considers:

* Article count.
* Independent source count.
* Freshness.
* Materiality.

Insufficient source diversity causes the evidence to become unavailable rather than allowing duplicated/repeated headlines to create artificial conviction.

### External Context Architecture

External context is accessed through a replaceable provider architecture.

Current implementation uses:

`MockExternalContextProvider`

Therefore current:

* Market Breadth.
* Earnings/macro event timing.
* News Sentiment.

are **synthetic development values**.

They validate architecture, orchestration, evidence-family de-duplication, confidence modification and UI behavior only.

They must not be presented as live market intelligence.

---

## 8. Trader Analysis Context

The Trader Analysis Context currently includes:

* Primary Analysis Interval.
* Timeframe Alignment.
* Market Environment.
* Market Breadth.
* Relative Strength.
* Event Risk.
* News Sentiment.

Every Analysis Context metric has its own explainability path.

Semantic roles are explicit:

* Primary Analysis Interval — context/configuration.
* Timeframe Alignment — directional/evaluative.
* Market Environment — directional/evaluative.
* Market Breadth — directional/evaluative.
* Relative Strength — directional/evaluative.
* Event Risk — confidence/risk-only.
* News Sentiment — directional/evaluative.

The card-level Analysis Context explanation remains available as a general overview.

Metric-specific explanations provide, where applicable:

* What the metric means.
* How it is calculated.
* Why it matters.
* Supportive interpretation.
* Opposing interpretation.
* Neutral interpretation.
* Recommendation impact.
* Explicit impact boundary.
* Limitations.

---

## 9. Explainability Requirements

Explainability is a permanent product requirement.

Every user-facing metric, evidence item, context value, historical statistic, decision helper, recommendation component and future analysis data point must provide an individual explanation path.

The normal UI must remain human-readable and simple.

A user should be able to understand the primary meaning of a card or value without understanding the internal scoring engine.

Preferred presentation pattern:

1. Human conclusion first.
2. Important quantitative value second.
3. Technical/statistical detail behind the info path.

A card-level general information dialog does not replace the requirement for individual metric/input explainability.

Every individual user-facing analytical input/value must have its own visible info affordance.

The explanation should cover, where applicable:

1. What the value means.
2. How it is calculated.
3. Why it matters.
4. Supportive interpretation.
5. Opposing interpretation.
6. Neutral interpretation.
7. How it affects recommendation direction.
8. How it affects confidence.
9. How it affects risk or entry quality.
10. Evidence-family/de-duplication implications.
11. Important limitations.

### Semantic roles

Every explainable analytical metric belongs to one explicit semantic role.

#### Directional / evaluative

May affect directional interpretation.

Supportive and opposing interpretations are required wherever mathematically meaningful.

#### Confidence / risk only

May alter confidence or risk but cannot create Buy/Sell direction.

Its permitted effect must be explicitly bounded.

Current permanent examples:

* Event Risk — maximum 12-point confidence penalty and cannot create a positive confidence bonus.
* Historical Setup Validation — maximum ±8-point final-confidence adjustment.

#### Context / configuration

Explains analysis state without manufacturing artificial bullish/bearish meaning.

### Direction attribution

Direction influence and confidence contribution remain separate.

User-facing direction attribution percentages must represent actual current-case effective contribution.

The active directional basis must reconcile to 100% after:

* Strategy-specific weighting.
* Reliability.
* Contextual adjustment.
* Signal magnitude.
* Evidence-family aggregation.
* Family caps.
* Correlation de-duplication.

Configured base weights are not the same thing as actual current-case attribution.

A family with no active directional contribution is excluded from the 100% denominator.

Provider shares shown inside a family must reconcile to that family's capped contribution.

Supportive and opposing influence must remain identifiable.

### Confidence attribution

Confidence attribution remains separate from directional attribution.

Evidence-derived confidence should explain, where relevant:

* Coverage.
* Reliability.
* Agreement.
* Conflict.
* Independent family coverage.
* Family confidence contribution.

Confidence-only modifiers remain explicit bounded point adjustments rather than being falsely normalized into the directional 100% basis.

Examples:

* Event Risk: `-6 confidence points`.
* Historical Setup Validation: `+4 confidence points`.

Final confidence conceptually reconciles as:

Evidence-derived confidence
+/- bounded confidence modifiers
= Final confidence

Automated tests must protect explainability completeness, semantic-role behavior, evidence-family de-duplication and attribution reconciliation.

---

## 10. Current Architecture

Conceptually:

Market snapshot + fixed historical baseline

→ Stock DNA / structural profile / volatility regime

→ Selected strategy and analysis interval

→ Multi-timeframe strategy context

→ Market / sector / relative-strength context

→ External context

→ Evidence providers

→ Contextual evidence adjustment

→ Evidence report

→ Evidence-family aggregation and de-duplication

→ Consensus Engine

→ Evidence-derived recommendation and confidence

→ Event-risk confidence adjustment

→ Historical Setup Validation

→ Final strategy-specific recommendation

→ Explainability / attribution / presentation

→ Future AI Analyst / Mentor

---

## 11. Validation Status

Validated releases and checkpoints include:

* v0.4.0 — 122 passing tests.
* v0.5.0 — at least 131 passing tests before later Recommendation Insight refinement.
* v0.6.0 — 147 passing tests.
* v0.7.0 — completed.
* v0.8.0 — completed.
* v0.9.0 — committed and tagged.
* v0.10.0 — 241 passing tests and zero analyzer issues; all six documented visual acceptance checks passed.
* v0.10.1 implementation — 263 passing tests and zero analyzer issues; 47 provider regression tests passed and all six documented v0.10.1 visual acceptance checks passed.

v0.10 release validator:

`./tools/validate-release-0.10.sh`

v0.10.0 was validated on 2026-08-22 with:

* 185 Dart files formatted.
* 0 formatting changes required.
* Flutter analyze: no issues.
* Flutter test: 241 tests passed.

v0.10.1 was validated on 2026-08-23 with:

* Flutter analyze: no issues.
* Flutter test: 263 tests passed.
* Provider regression suite: 47 tests passed.
* All six documented v0.10.1 visual acceptance checks passed.

---

## 12. Current Limitations

* Primary market data remains mocked.
* Historical data remains mocked/synthetic where documented.
* External context remains synthetic through `MockExternalContextProvider`.
* News Sentiment is not yet connected to authoritative live news sources.
* Earnings and macro-event data are not yet connected to authoritative event sources.
* Market Breadth is not yet connected to authoritative live breadth data.
* Same-time-of-day historical RVOL requires real matching intraday sessions and remains deferred.
* Stock DNA does not yet use sector/peer percentiles.
* True session VWAP remains deferred until authoritative session-aware intraday data is available.
* Swing v0.11.0 implementation and release acceptance are complete; market, external-context and historical inputs remain synthetic where documented, so this is not yet a live-data production release.
* Investor fundamental brain is not implemented.
* AI Analyst/Mentor is not connected.
* Synthetic historical outcomes cannot be interpreted as real strategy performance.

---

## 13. Permanent Architecture and Product Rules

1. Research major competitor implementations before designing major features.
2. Do not turn the recommendation brain into a simple indicator-majority vote.
3. Correlated evidence cannot create artificial confidence.
4. Evidence-family de-duplication is mandatory.
5. Treat steady and volatile stocks differently using stock-specific historical context.
6. Keep structural stock behavior separate from current volatility regime.
7. Do not fabricate data a provider does not actually possess.
8. Direction and confidence remain separate.
9. Direction attribution and confidence attribution remain separate.
10. Every detailed analysis output belongs explicitly to Trader, Swing or Investor.
11. Strategy Summary establishes the selected strategy context.
12. AI explains deterministic/statistical analysis; AI does not invent recommendations.
13. Presentation must remain replaceable without rewriting domain/business logic.
14. Every important user-facing measurement requires an explainability path.
15. Directional/evaluative data must support both positive and negative interpretations where meaningful.
16. Historical validation cannot independently determine recommendation direction.
17. External validation/modifiers must be shown separately from evidence-derived confidence.
18. Mock and synthetic development data must always be explicitly identified.
19. Price History visualization remains independent from recommendation-analysis timeframe.
20. Every incremental patch/hotfix/refinement receives its own semantic version.
21. Significant functionality must be documented during the same development cycle in which it is introduced.
22. Project documentation, not conversation history, is the authoritative persistent record of project decisions.
23. Every user-facing card, evidence item, decision helper, metric and input must be understandable in plain human language.
24. Every individual user-facing analytical input/value must have its own info/explainability path.
25. Direction attribution percentages must reconcile to 100% of the active post-de-duplication directional basis.
26. Confidence attribution must remain separate from directional attribution; confidence-only modifiers are shown as bounded point adjustments rather than fake evidence percentages.

---

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

## 14. Immediate Project Action

Current tagged release:

**v0.11.0 — Swing Strategy Brain** (`665fd8f`, tag `v0.11.0`)

Active development release:

**v0.12.0 — Investor Strategy Brain**

Approved detailed scope:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

Current checkpoint:

**Batches 1–10 implemented, regression-validated and visually accepted for the v0.11.0 release checkpoint.**

Completed production foundations:

1. Strategy-aware evidence/applicability policy and execution gates.
2. Swing timeframe/context orchestration.
3. Trend and Momentum Swing calibration.
4. Participation, Price Structure and Volatility Swing calibration.
5. Market Context, Sentiment, Stock DNA and Event Risk Swing calibration.
6. Swing Historical Setup Validation calibration and dataset/horizon integrity.
7. Swing recommendation decision policy and multi-strategy backend orchestration.
8. Recommendation attribution integrity, reconciliation and user-facing explainability.

Batch 8 attribution contract:
* Family direction attribution is calculated after evidence-family aggregation and caps.
* Active family direction shares reconcile to 100% of the current directional basis.
* Provider signed direction impacts reconcile to capped family contribution.
* Provider internal shares are not presented as percentages of the recommendation.
* Family-level percentages are the primary user-facing direction attribution.
* Provider detail uses signed direction points.
* Direction attribution and confidence attribution remain separate.
* Confidence-modifier sources are explicitly classified as evidence quality, Event Risk or Historical Validation.
* Evidence-derived confidence remains separate from Event Risk and Historical Validation.
* Final confidence reconciles from evidence-derived confidence plus allowed bounded external point adjustments.
* Event Risk remains confidence-only with zero direction and maximum -12 points.
* Historical Setup Validation remains confidence-only with zero direction and maximum ±8 points.
* Every displayed attribution metric has an individual MetricExplainability info path.
* Attribution explainability includes calculation, role, impact and limitations.
* Confidence is explicitly not presented as a probability of profit.

Batch 8 functional validation baseline:

* Flutter analyzer: clean.
* Recommendation subsystem suite: 439 passing tests.
* Full automated suite: 512 passing tests.

The Swing backend, recommendation policy, orchestration and attribution contract
are implemented and validated.

Batch 9A implementation checkpoint:

* Swing is selectable in the visible Strategy Summary.
* A strategy that is implementation-ready but has no cached result is shown as `Ready to analyze` rather than `Coming Soon`.
* Selecting Swing runs the existing Swing backend and displays Swing-specific Analysis Context, Recommendation, Recommendation Insight, Evidence and Risk.
* Trader and Swing continue to use independent cached recommendation states.
* Investor remains unavailable and `Coming Soon`.
* Batch 9A does not change scoring weights, evidence direction, family caps, attribution mathematics, Event Risk or Historical Setup Validation behavior.
* Decision helpers remain outstanding work inside Batch 9 and must not create duplicate evidence votes.

Batch 9A validation:

* Focused Strategy Summary / dashboard / top-level UI gate: 8 passing tests.
* Recommendation subsystem suite: 441 passing tests.
* Dashboard subsystem suite: 5 passing tests.
* Flutter analyzer: clean.
* `git diff --check`: clean.
* Full automated suite: 514 passing tests.

Batch 9B implementation checkpoint:

* Added a Swing-only `Swing Decision Helper` presentation layer.
* Decision Helpers expose three human-readable outputs: `Entry Quality`, `Price Stretch` and `Structure Watch`.
* `Price Stretch` is derived from existing Swing Price Extension evidence.
* `Structure Watch` is derived from existing Swing Support & Resistance evidence.
* `Entry Quality` summarizes existing recommendation/evidence state without creating a proprietary numeric score.
* Decision Helpers consume already-computed typed evidence and do not feed back into the Consensus Engine.
* Decision Helpers add exactly zero new evidence votes, zero direction points and zero confidence points.
* Each helper has an individual `MetricExplainability` info path covering inputs, calculation, role, impact boundary and limitations.
* Trader does not display the Swing Decision Helper.
* Investor remains unavailable / Coming Soon.
* No Batch 9B change modifies evidence providers, scoring weights, recommendation thresholds, family caps, attribution mathematics, Event Risk or Historical Setup Validation behavior.

Batch 9B validation:

* Focused Decision Helper / top-level UI gate: 9 passing tests.
* Recommendation subsystem suite: 449 passing tests.
* Flutter analyzer: clean.
* `git diff --check`: clean.
* Full automated suite: 522 passing tests.
* Manual Chrome visual acceptance: passed on 2026-08-31.

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

Current next implementation work:

**v0.12.0 — Investor Strategy Brain, after the v0.11.0 release checkpoint is committed, pushed and tagged.**

Permanent Swing acceptance constraints:

* Swing is not Trader on slower candles.
* Human-readable cards and decision helpers.
* Individual info paths for every user-facing analytical input/value.
* BUY/SELL parity wherever mathematically meaningful.
* Direction attribution reconciles to 100% of active post-family-cap directional influence.
* Provider attribution reconciles to capped family attribution.
* Confidence attribution remains separate from direction attribution.
* Event Risk remains confidence-only with a maximum 12-point penalty.
* Historical Setup Validation remains confidence-only with a maximum ±8-point adjustment.
* Current analysis-window VWAP is not automatically valid Swing evidence.
* RSI must not use a simplistic overbought-equals-SELL / oversold-equals-BUY Swing rule.
* Price Extension must not automatically claim trend reversal.
* Support/resistance proximity alone must not create confirmed direction.
* 4H Relative Volume must not fabricate time-of-day normalization.
* Synthetic/mock data remains explicitly identified.

Approved roadmap:

* v0.11.0 — Swing Strategy Brain.
* v0.12.0 — Investor Strategy Brain.
* v1.0.0 — validated multi-strategy milestone.
