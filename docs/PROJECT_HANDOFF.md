# TradePilot AI — Project Handoff

**Document:** Project Continuation / Chat Handoff
**Version:** 1.2
**Checkpoint:** v0.12.0 — Investor Strategy Brain Batch 5 Revisions + Competitive Durability Validated
**Date:** 2026-08-31
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

Previous tagged baseline release:

**v0.10.1 — Explainability & Bidirectional Audit**

Release commit:

`c53ad00 — docs: finalize v0.10.1 explainability release`

v0.10.1 is complete, tagged and synchronized with GitHub.

Current release checkpoint:

**v0.11.0 — Swing Strategy Brain**

Status:

**Release acceptance complete — Batches 1–10 implemented and validated; designated release tag: `v0.11.0`.**

Detailed evidence, capability and acceptance contract:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

Swing now has a validated strategy-specific backend, visible Strategy Summary activation, presentation-only Decision Helpers, typed recommendation-state reasons and human-readable non-action wording. Final v0.11.0 release acceptance passed on 2026-08-31.

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

The user prefers concise surgical/transactional patch scripts when safe. Use complete-file replacements only for substantial restructuring or when a surgical patch would be brittle or unsafe.

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

## Current Known Limitations

The project is not yet production-ready.

Important limitations include:

* Market data is still mocked.
* External market/news/event context is synthetic.
* Historical outcomes used for architecture validation are synthetic.
* Real market/news/event providers are not connected.
* Same-time-of-day historical RVOL is not implemented.
* True session VWAP requires authoritative intraday/session data.
* Swing brain is implemented and v0.11.0 release acceptance is complete; synthetic/mock data limitations still prevent interpreting this checkpoint as live production market intelligence.
* Investor production recommendation generation is still unavailable; v0.12.0 Batch 5 Revisions + Competitive Durability is implemented and validated. Competitive Durability remains overlap-gated from independent core breadth pending Batch 8.
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

Current tagged release:

**v0.11.0 — Swing Strategy Brain** (`665fd8f`, tag `v0.11.0`)

Active development release:

**v0.12.0 — Investor Strategy Brain**

Detailed architecture/research contract:

`docs/INVESTOR_STRATEGY_BRAIN_V0_12.md`

The approved evidence-by-evidence audit is authoritative during implementation.

Immediate sequence:

1. Keep Investor unavailable; Investor remains deferred to v0.12.0.
2. Preserve Batch 9B Decision Helpers as presentation-derived summaries only; they must not become evidence votes or alter confidence/direction.
3. Preserve the accepted v0.11.0 release checkpoint; do not alter its scoring/recommendation behavior without a new semantic version.
4. Commit, push and tag the accepted v0.11.0 checkpoint, then continue with v0.12.0 Investor Strategy Brain planning/implementation.

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

## Handoff Principle

**The repository remembers the project. The conversation assists with the project.**

A ChatGPT conversation is not the permanent system of record.

When conversation context and current repository documentation disagree, inspect the implementation and current documentation before proceeding.
