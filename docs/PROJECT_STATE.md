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

Batch 1 foundation implemented and validated.

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
* Investor — v0.12.0 Batch 1 domain/family/provider-contract foundation implemented and validated; production recommendation remains unavailable.
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
