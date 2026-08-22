# TradePilot AI

Document ID:
TP-010

Document:
Project Changelog

Version:
1.1

Status:
Approved

Last Updated:
2026-08-23

Owner:
TradePilot AI

Related Documents:
- TP-001 Master Specification
- TP-009 Project Roadmap

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
