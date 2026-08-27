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
2026-08-27

Owner:
TradePilot AI

Related Documents:
- TP-001 Master Specification
- TP-009 Project Roadmap

---

## v0.11.0 — Swing Strategy Brain

Status

Development — Batches 1-5 Complete

Date

2026-08-23

Summary

Opened v0.11.0 as the dedicated Swing Strategy Brain release.

This checkpoint defines architecture, evidence applicability, explainability, attribution and acceptance requirements before production implementation begins.

No production recommendation behavior has changed in this checkpoint.

### Implementation Progress — 2026-08-27

Batches 1-5 are implemented and regression-validated.

Completed:
- Strategy-aware evidence policy and collection gates.
- Swing timeframe/context orchestration.
- Trend and Momentum family calibration.
- Participation, Price Structure and Volatility/Entry Quality calibration.
- Market & Sector Context / Relative Strength calibration.
- Market Breadth calibration inside the shared Market Context family.
- News Sentiment freshness/materiality/source-diversity/de-duplication calibration.
- Stock DNA strategy-aware contextual adjustment.
- Swing Event Risk horizon and confidence-only enforcement.
- Current analysis-window VWAP remains excluded from Swing.
- Trader regression protection and strategy-readiness invariants.

Batch 5 semantic boundaries:
- Market Context and Market Breadth cannot become two independent market votes.
- News Sentiment requires sufficient freshness, materiality and de-duplicated independent-story coverage before it may create Swing direction.
- Repeated headline count cannot multiply Swing News Sentiment weight after the minimum coverage gate is satisfied.
- Stock DNA requires the daily historical baseline for Swing and changes existing evidence weight only.
- Stock DNA cannot create or flip direction, create another evidence vote, or change evidence score/reliability.
- Event Risk remains outside directional evidence and directional attribution.
- Swing Event Risk considers earnings up to 14 days and high-impact macro events up to 7 days.
- Event Risk can never add confidence and remains hard-capped at -12 confidence points.
- Event Risk cannot change direction score or evidence-derived confidence.
- External market/news/event development context remains explicitly synthetic.

Functional validation at Batch 5 implementation completion:
- Flutter analyzer: clean.
- Provider regression suite: 133 passing tests.
- Full automated suite: 467 passing tests.

Swing recommendation generation remains intentionally inactive.

Next planned implementation work:

**Batch 6 — Swing Historical Setup Validation.**

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
