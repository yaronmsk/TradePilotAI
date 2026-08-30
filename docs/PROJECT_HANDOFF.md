# TradePilot AI — Project Handoff

**Document:** Project Continuation / Chat Handoff
**Version:** 1.2
**Checkpoint:** v0.11.0 — Scope Approved
**Date:** 2026-08-23
**Primary Branch:** `develop`

---

## Purpose

This document allows TradePilot AI development to continue safely across new ChatGPT conversations without relying on the previous conversation's context window.

The repository documentation is the authoritative source of truth.

Conversation memory may provide useful background but must not override current repository documentation.

---

## Project

**Name:** TradePilot AI

TradePilot AI is a mobile-first stock-analysis application designed to monitor selected stocks and produce strategy-specific, statistics-based recommendation analysis.

The product intentionally avoids framing its output as guaranteed prediction.

Recommendations must be explainable, quantitatively grounded and risk-aware.

The architecture is designed for future Android and iOS support through Flutter.

---

## Current Development Philosophy

Development is currently **brain-first**.

Priority order:

1. Recommendation quality.
2. Statistical validity.
3. Stock-specific context.
4. Evidence de-duplication.
5. Explainability.
6. Risk awareness.
7. Historical validation.
8. Real-data integration.
9. AI explanation.
10. Final commercial UI/design.

The existing UI is functional/provisional.

Do not initiate a major visual redesign unless the project documentation explicitly advances the project into that phase.

---

## Current Release Checkpoint

Current tagged release:

**v0.10.1 — Explainability & Bidirectional Audit**

Release commit:

`c53ad00 — docs: finalize v0.10.1 explainability release`

v0.10.1 is complete, tagged and synchronized with GitHub.

Current active development release:

**v0.11.0 — Swing Strategy Brain**

Status:

**Production implementation active — Batches 1–8 complete; Batch 9A Swing UI activation implemented and validated.**

Detailed evidence, capability and acceptance contract:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

Swing now has a validated strategy-specific backend and is activated in the visible Strategy Summary through Batch 9A. Decision-helper completion and final v0.11.0 validation remain in progress.

Swing must not be implemented as Trader logic running on slower candles.

Before Swing activation, every existing evidence provider, context input, confidence modifier, historical capability and decision helper requires an explicit Swing applicability/calibration decision.

Approved roadmap:

* v0.11.0 — Swing Strategy Brain.
* v0.12.0 — Investor Strategy Brain.
* v1.0.0 — validated Trader + Swing + Investor multi-strategy milestone.

---

## v0.10.1 Scope

v0.10.1 converts TradePilot AI's permanent explainability requirements into reusable and automatically tested architecture.

Implemented:

* Reusable `MetricExplainability` contract.
* Explicit semantic roles:
  * Directional/evaluative.
  * Confidence/risk-only.
  * Context/configuration.
* Central explainability catalog for every production `EvidenceKind`.
* Individual explainability paths for all seven Trader Analysis Context metrics.
* Shared explainability rendering rather than widget-specific explanation architecture.
* Historical Setup Validation supportive/opposing explainability.
* Historical Setup Validation hard-bounded to ±8 final-confidence points.
* Event Risk hard-bounded to a maximum 12-point confidence penalty.
* Event Risk prohibited from producing positive confidence bonuses or directional evidence.
* Automated explainability-completeness and semantic-role tests.
* Provider BUY/SELL and bidirectional regression audit.
* Existing evidence-family de-duplication and direction/confidence attribution preserved.

---

## v0.10 Scope

v0.10 adds:

### Market Breadth

* Market Context evidence.
* De-duplicated with Market & Sector Context.
* Cannot independently inflate family confidence.

### Event Risk

* Scheduled earnings/macro catalyst awareness.
* Confidence-only modifier.
* Cannot change recommendation direction directly.
* Maximum confidence penalty: 12 points.

### News Sentiment

* Independent Sentiment evidence family.
* Reliability based on source count/diversity, freshness and materiality.
* Insufficient source diversity makes evidence unavailable.

### External Context Provider

External context uses a replaceable provider architecture.

Current provider:

`MockExternalContextProvider`

Current external values are synthetic development data and must not be represented as live intelligence.

---

## Previous Major Capability — v0.9

Historical Setup Validation provides bounded historical analog analysis.

Important safeguards:

* Setup fingerprints use setup-time information only.
* Future outcome data is evaluation-only.
* Historical validation does not create an independent evidence family.
* Stock Profile is a hard eligibility gate.
* Context-matched same-stock comparison is required.
* Minimum 12 eligible baseline observations before confidence influence.
* Historical validation cannot change direction by itself.
* Confidence effect capped at ±8 points.
* Positive confidence credit requires historical setups to outperform both:

  * 50% directional follow-through.
  * Context-matched same-stock baseline.
* Historical confidence impact is shown separately from evidence-derived confidence.
* Current historical results are synthetic and are not real strategy-performance evidence.

---

## Core Brain Architecture

The recommendation pipeline conceptually follows:

Market Data

→ Historical Stock Data

→ Stock DNA

→ Strategy / Analysis Interval

→ Multi-Timeframe Context

→ Market / Sector / Relative Context

→ External Context

→ Evidence Providers

→ Contextual Evidence Adjustment

→ Evidence-Family De-duplication

→ Consensus Engine

→ Evidence-Derived Direction + Confidence

→ Confidence-Only External Modifiers

→ Historical Setup Validation

→ Final Strategy Recommendation

→ Explainability / Attribution

→ Presentation

→ Future AI Analyst / Mentor

---

## Active Strategy

### Trader

Implemented and active.

Primary analysis interval can be selected from:

* 1m
* 5m
* 15m
* 30m
* 1h

Confirmation/backdrop intervals adapt automatically.

### Swing

v0.11.0 active development.

Visible Strategy Summary activation is now implemented in Batch 9A. Swing can be selected and runs its existing strategy-specific backend; remaining Batch 9 work is limited to decision-helper completion and final validation.

Approved default timeframe plan:

* 1D primary.
* 1W confirmation.
* 1M regime.

Approved alternate timeframe plan:

* 4H primary.
* 1D confirmation.
* 1W regime.

Detailed evidence applicability and calibration are defined in:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

### Investor

Planned / Coming Soon.

All detailed recommendation information must explicitly belong to the selected strategy.

---

## Evidence Architecture

Current evidence families include:

* Trend.
* Momentum.
* Participation.
* Price Structure.
* Volatility.
* Market Context.
* Sentiment.

Multiple providers may exist inside one family.

Providers inside a family are correlated and therefore must not automatically count as independent votes.

Family aggregation/caps protect confidence from correlation inflation.

---

## Permanent Explainability Rule

Every user-facing metric, evidence item, context value, historical statistic and future feature data point must provide an explanation path describing, where applicable:

* What it means.
* How it is calculated.
* Why it matters.
* Direction impact.
* Confidence impact.
* Risk impact.
* Important limitations.

Every directional/evaluative input must represent both supportive and opposing outcomes wherever logically meaningful.

Direction influence must not be confused with confidence contribution.

Provider attribution must reconcile with evidence-family aggregation.

v0.10.1 makes explainability a domain-level contract rather than a collection of widget-specific strings.

Semantic roles are permanent architecture:

### Directional / evaluative

May influence directional interpretation.

Supportive and opposing interpretations are required where mathematically meaningful.

### Confidence / risk only

May alter confidence or risk within an explicit bound but cannot create Buy/Sell direction.

Current permanent bounds:

* Event Risk — maximum 12-point confidence penalty and no positive confidence bonus.
* Historical Setup Validation — maximum ±8-point final-confidence adjustment.

Neither may modify evidence-derived direction.

Historical Setup Validation also preserves evidence-derived confidence separately from its final-confidence modifier.

### Context / configuration

Describes analysis state or configuration without manufacturing bullish/bearish meaning.

Primary Analysis Interval is the current example.

Automated tests enforce explainability completeness and semantic-role behavior.

---

## AI Rule

Future AI functionality is an explanation/analysis layer over deterministic and statistical systems.

AI must not fabricate the underlying recommendation.

The deterministic/statistical engine remains inspectable and independently testable.

---

## Data Integrity Rules

Never fabricate unavailable data.

Synthetic/mock values must be clearly labeled.

Do not silently substitute mock data for real data in production behavior.

Historical future outcomes cannot leak into setup fingerprints.

Correlated indicators cannot artificially increase independent evidence coverage.

External validation cannot silently overwrite evidence-derived confidence.

---

## UI Rules

The UI remains modular and replaceable.

Permanent presentation rules:

* Strategy Summary establishes strategy context.
* Analysis Context appears directly beneath Strategy Summary.
* Recommendation details belong explicitly to the selected strategy.
* Primary user-facing concepts must remain understandable in plain human language.
* Technical complexity belongs behind explainability or expandable details.
* Every individual analytical input/value requires its own visible info/explainability path.
* A card-level general information dialog does not replace individual metric explanations.
* Evidence items must explain both supportive and opposing meaning where mathematically appropriate.
* BUY and SELL analysis receive equivalent analytical treatment.
* Decision helpers must summarize real underlying evidence and cannot become unexplained proprietary scores.
* A value such as Momentum, Trend Quality, Entry Quality or Alignment must not appear as an unexplained number.

### Attribution UI

Direction attribution and confidence attribution are separate.

User-facing direction percentages must represent actual current-case influence after:

* Strategy-specific weighting.
* Reliability.
* Contextual adjustment.
* Signal magnitude.
* Evidence-family aggregation.
* Family caps.
* Correlation de-duplication.

The active direction basis must reconcile to 100%.

Provider-level shares must reconcile to their capped family contribution.

Configured base weights must not be displayed as though they were actual current-case contribution.

Confidence-only modifiers remain explicit point adjustments.

Examples:

* Event Risk: negative confidence points only, maximum -12.
* Historical Setup Validation: bounded ±8 confidence points.

They are not normalized into the direction-attribution 100%.

---

## Repository / Workflow

Primary development branch:

`develop`

Repository:

`TradePilotAI`

Flutter application:

`mobile/`

Important documentation is under:

`docs/`

Release validators are under:

`tools/`

Before modifying the project, inspect at minimum:

1. `docs/PROJECT_HANDOFF.md`
2. `docs/PROJECT_STATE.md`
3. `docs/PROJECT_BIBLE.md`
4. `docs/BRAIN_ARCHITECTURE.md`
5. `docs/BRAIN_FEATURE_PLAN.md`
6. `docs/CHANGELOG.md`

Read additional specifications relevant to the feature being changed.

Do not rely solely on this handoff document when a detailed specification exists.

---

## Development Workflow

For meaningful feature work:

1. Understand current documented architecture.
2. Check existing implementation before proposing changes.
3. Research major competitor implementations when required by project rules.
4. Define the feature's evidence family/context role.
5. Define positive and negative interpretations.
6. Define direction/confidence/risk effects.
7. Define explainability.
8. Protect against correlation/double counting.
9. Implement modularly.
10. Add tests.
11. Run analyzer/tests.
12. Perform required visual validation.
13. Update documentation.
14. Assign the correct semantic version.
15. Commit and push the checkpoint.

The user prefers complete file contents when manual file replacement is required rather than fragmented patches.

Provide exact commands for actions the user must perform.

Prefer internally consistent, compile-ready batches rather than many tiny disconnected edits.

---

## Versioning

TradePilot AI follows semantic versioning.

Permanent project rule:

Every incremental patch/hotfix/refinement receives its own version.

Examples:

* `v0.10.0` — feature release.
* `v0.10.1` — first patch/refinement.
* `v0.10.2` — subsequent patch/refinement.
* `v0.11.0` — next significant feature release.

Do not silently modify a completed release without advancing its version appropriately.

---

## Current Known Limitations

The project is not yet production-ready.

Important limitations include:

* Market data is still mocked.
* External market/news/event context is synthetic.
* Historical outcomes used for architecture validation are synthetic.
* Real market/news/event providers are not connected.
* Same-time-of-day historical RVOL is not implemented.
* True session VWAP requires authoritative intraday/session data.
* Swing brain is not implemented.
* Investor fundamental brain is not implemented.
* AI Analyst/Mentor is not connected.
* Historical validation results are not real backtested strategy-performance claims.

---

## Instructions for a New ChatGPT Development Conversation

When starting a new conversation:

1. Treat repository documentation as authoritative.
2. Read this handoff and current project state before proposing implementation.
3. Do not redesign established architecture without identifying the conflict and discussing it first.
4. Preserve all permanent product and explainability rules.
5. Do not introduce unsolicited scope expansion.
6. Keep Trader / Swing / Investor contexts explicit.
7. Preserve evidence-family de-duplication.
8. Preserve separation between direction and confidence.
9. Preserve separation between evidence-derived confidence and external validation/modifiers.
10. Never present synthetic development data as real market intelligence.
11. Update project documentation whenever a permanent decision or meaningful feature is introduced.
12. Maintain semantic release versioning.

---

## Immediate Continuation Point

Active development release:

**v0.11.0 — Swing Strategy Brain**

Detailed implementation contract:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

The approved evidence-by-evidence audit is authoritative during implementation.

Immediate sequence:

1. Complete Batch 9A final regression validation and documentation synchronization.
2. Keep Investor unavailable; Investor remains deferred to v0.12.0.
3. Continue Batch 9 with decision helpers derived only from existing evidence, without creating duplicate votes.
4. Complete full v0.11.0 regression/visual validation before the release checkpoint.

For every existing evidence/capability, determine:

* Whether Swing uses it.
* Why it matters to Swing.
* Correct timeframe and lookback.
* Calculation/threshold changes.
* Direction effect.
* Confidence effect.
* Risk or entry-quality effect.
* Evidence-family relationship.
* BUY/SELL interpretation.
* User-facing wording.
* Individual info/explainability behavior.
* Attribution behavior.
* Limitations.

Permanent v0.11.0 constraints:

* Swing is not Trader on slower candles.
* Main UI remains human-readable.
* Every analytical input/value has an individual info path.
* Direction attribution reconciles to 100% of active effective directional influence.
* Provider attribution reconciles to capped family attribution.
* Confidence attribution remains separate.
* Evidence-family de-duplication remains mandatory.
* Event Risk remains confidence-only and capped at a maximum 12-point penalty.
* Historical Setup Validation remains confidence-only and capped at ±8 points.
* Current analysis-window VWAP is not automatically valid Swing evidence.
* RSI must not use simplistic overbought-equals-SELL / oversold-equals-BUY Swing semantics.
* Price Extension must not automatically claim trend reversal.
* Support/resistance proximity alone is not confirmed directional evidence.
* 4H Relative Volume must not fabricate same-time-of-day normalization.
* Synthetic/mock data honesty remains mandatory.

---

## Handoff Principle

**The repository remembers the project. The conversation assists with the project.**

A ChatGPT conversation is not the permanent system of record.

When conversation context and current repository documentation disagree, inspect the implementation and current documentation before proceeding.
