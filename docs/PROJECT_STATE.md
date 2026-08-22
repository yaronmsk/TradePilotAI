# TradePilot AI Project State

**Document ID:** TP-012
**Version:** 2.0
**Status:** Active
**Last Updated:** 2026-08-23
**Primary Branch:** `develop`

---

## 1. Current Release Baseline

Current completed implementation baseline:

**v0.10.1 — Explainability & Bidirectional Audit**

Previous tagged release:

**v0.10.0 — Market, Event & News Context**

v0.10.1 implementation validation completed successfully on 2026-08-23:

* Flutter analyze: no issues.
* Flutter test: 263 tests passed.
* Provider regression audit: 47 tests passed.
* All six documented v0.10.1 visual acceptance checks passed.
* Final implementation checkpoint before release documentation: `15c352c`.

Implemented v0.10.1 checkpoints:

* `0b5f064` — reusable explainability contracts.
* `00199af` — Historical Setup Validation explainability and confidence-bound enforcement.
* `15c352c` — explainability invariant enforcement.

The implementation is complete and synchronized with `origin/develop`.

The remaining v0.10.1 release actions are:

1. Complete canonical documentation updates.
2. Run final release validation.
3. Commit and push the release documentation.
4. Create and push the `v0.10.1` tag.

---

## 2. Current Development Phase

**Brain-first feature development.**

The priority remains recommendation quality, stock-specific context, statistical discipline, explainability and risk awareness.

The current UI is functional and intentionally provisional.

A dedicated commercial UI/design phase remains deferred until the analysis capability is sufficiently mature.

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

* Trader — active.
* Swing — planned / Coming Soon.
* Investor — planned / Coming Soon.
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

Every user-facing metric, evidence item, context value, historical statistic and future analysis data point must provide an explanation path covering, where applicable:

1. What the value means.
2. How it is calculated.
3. Why it matters.
4. How it affects direction.
5. How it affects confidence.
6. How it affects risk.
7. Important limitations.

Directional and evaluative inputs must represent both supportive and opposing outcomes wherever logically meaningful.

One-sided evidence logic should be avoided.

Direction influence and confidence contribution must remain explicitly separated.

Provider attribution must respect evidence-family aggregation and family caps.

v0.10.1 makes these rules enforceable through the reusable `MetricExplainability` architecture.

Every explainable metric is classified into one of three semantic roles:

### Directional / evaluative

These metrics may affect directional interpretation.

Where mathematically meaningful they must define supportive, opposing and neutral/unknown interpretations.

### Confidence / risk only

These metrics may modify confidence or risk but cannot create Buy/Sell direction.

Their permitted effect must be explicitly bounded.

Current examples:

* Event Risk — maximum 12-point confidence penalty and cannot produce a confidence bonus.
* Historical Setup Validation — maximum ±8-point final-confidence adjustment.

Neither may modify evidence-derived direction.

Historical Setup Validation also preserves evidence-derived confidence separately from its final-confidence modifier.

### Context / configuration

These values explain analysis configuration or state without manufacturing bullish/bearish meaning.

Primary Analysis Interval is the current example.

### Explainability catalogs

Production evidence definitions are covered by a central explainability catalog keyed by `EvidenceKind`.

Trader Analysis Context has a separate complete explainability catalog covering all seven displayed metrics.

Historical Setup Validation uses the same reusable explainability contract.

Automated tests enforce explainability completeness and semantic-role invariants.

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
* Swing recommendation brain is not implemented.
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

---

## 14. Immediate Project Action

Complete the formal **v0.10.1 — Explainability & Bidirectional Audit** release checkpoint:

1. Complete and validate the canonical documentation updates.
2. Commit and push the release documentation.
3. Confirm the working tree is clean.
4. Create the annotated `v0.10.1` release tag.
5. Push the tag to GitHub.
6. Verify `origin/develop` and the release tag.

After v0.10.1 is formally released, do not invent the next major capability from conversation context.

Before beginning the next development phase:

1. Reconstruct the project from the six canonical continuation documents:
   * `PROJECT_HANDOFF.md`
   * `PROJECT_STATE.md`
   * `PROJECT_BIBLE.md`
   * `BRAIN_ARCHITECTURE.md`
   * `BRAIN_FEATURE_PLAN.md`
   * `CHANGELOG.md`
2. Confirm the next roadmap release/capability.
3. Present the proposed implementation approach before coding.
4. Preserve all permanent architecture and explainability invariants.

The following v0.10.1 rules are permanent regression constraints:

* Reusable explainability contracts.
* Semantic-role classification.
* Bidirectional interpretation where mathematically meaningful.
* Evidence-family de-duplication.
* Direction/confidence separation.
* Event Risk confidence-only behavior and 12-point maximum penalty.
* Historical Setup Validation confidence-only behavior and ±8-point maximum adjustment.
* BUY/SELL analytical parity.
