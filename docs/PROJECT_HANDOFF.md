# TradePilot AI — Project Handoff

**Document:** Project Continuation / Chat Handoff
**Version:** 1.1
**Checkpoint:** v0.10.1
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

**v0.10.1 — Explainability & Bidirectional Audit**

Previous release:

**v0.10.0 — Market, Event & News Context**

v0.10.1 implementation validation completed successfully on 2026-08-23:

* `flutter analyze`: no issues.
* `flutter test`: 263 tests passed.
* Provider regression audit: 47 tests passed.
* All six documented v0.10.1 visual acceptance checks passed.
* Final implementation checkpoint before release documentation: `15c352c`.

Implementation checkpoints:

* `0b5f064` — reusable explainability contracts.
* `00199af` — Historical Setup Validation explainability and confidence-bound enforcement.
* `15c352c` — explainability invariant enforcement.

The implementation is complete and pushed to `origin/develop`.

The final documentation commit and `v0.10.1` release tag are the remaining release-checkpoint actions.

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

Planned / Coming Soon.

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

Important current rules:

* Strategy Summary establishes strategy context.
* Analysis Context appears directly beneath Strategy Summary.
* Recommendation details belong to the selected strategy.
* Technical complexity should be hidden behind explainability/expandable details where possible.
* Primary user-facing concepts should remain understandable.
* Exceptional values may be visually emphasized.
* Historical comparisons should favor useful numerical/graphical context.
* Buy and sell analysis receive equivalent analytical treatment.
* Price History range is independent of recommendation-analysis interval.

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

Complete the formal **v0.10.1 — Explainability & Bidirectional Audit** release checkpoint:

1. Complete canonical documentation updates.
2. Run final release validation.
3. Commit and push the release documentation.
4. Confirm the working tree is clean.
5. Create the annotated `v0.10.1` tag.
6. Push the tag to GitHub.
7. Verify `origin/develop` and the release tag.

After v0.10.1 is formally released, do not invent the next major capability from conversation context.

Before beginning the next development phase:

1. Read the six canonical continuation documents.
2. Reconstruct the current architecture and permanent constraints.
3. Select the next significant capability from the documented roadmap.
4. Present the proposed implementation approach before coding.

Permanent regression constraints include:

* Reusable explainability contracts.
* Semantic-role classification.
* Bidirectional interpretation where mathematically meaningful.
* Evidence-family de-duplication.
* Direction/confidence separation.
* Event Risk confidence-only behavior and 12-point maximum penalty.
* Historical Setup Validation confidence-only behavior and ±8-point maximum adjustment.
* BUY/SELL analytical parity.
* Synthetic-data honesty.

---

## Handoff Principle

**The repository remembers the project. The conversation assists with the project.**

A ChatGPT conversation is not the permanent system of record.

When conversation context and current repository documentation disagree, inspect the implementation and current documentation before proceeding.
