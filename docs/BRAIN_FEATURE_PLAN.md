# TradePilot AI Brain Feature Plan

Research checkpoint: September 2026

## Product objective

The brain must answer a harder question than “what do the indicators say?”

It must answer:

> Given this strategy horizon, this stock's normal behavior, the current market regime, the quality and independence of the evidence, and known event/fundamental context, what conclusion is justified and how certain should we be?

## Data layers

### 1. Stock-specific historical context

Purpose: distinguish a structurally solid/steady stock from a structurally volatile stock, and distinguish both from a temporary volatility regime.

Planned inputs:
- 20/60/252-day ATR% distributions.
- Realized volatility percentiles.
- Daily volume distributions.
- Same-time-of-day intraday volume baselines.
- Gap frequency and gap size.
- Trend persistence / directional efficiency history.
- Drawdown behavior.
- Earnings-day volatility.

Output: long-horizon Stock DNA + current regime.

### 2. Price/trend structure

Trader/Swing inputs:
- Candle trend.
- EMA/SMA structure.
- MACD.
- ADX/trend quality.
- VWAP/anchored VWAP where appropriate.
- Support/resistance and breakout structure.

All related indicators map into evidence families so several price-derived signals cannot create artificial confidence.

### 3. Participation / volume

- Relative Volume.
- Same-time Relative Volume for intraday analysis.
- Price/volume confirmation.
- Accumulation/distribution-style behavior where data quality supports it.
- Future order-flow/volume-delta data only if the data source is reliable and licensing permits it.

### 4. Volatility / risk

Volatility is primarily context and risk, not directional evidence by itself.

- ATR% and normalized volatility.
- Volatility regime vs own history.
- Gap risk.
- Earnings/event risk.
- Future implied volatility when reliable options data is available.

Volatility changes thresholds, evidence weights, stop/risk interpretation and confidence.

### 5. Market and sector context

- Index trend/regime.
- Market breadth.
- Sector trend.
- Stock relative strength vs market and sector.
- Risk-on/risk-off context where measurable.

A bullish stock signal should not be interpreted identically in a strong market and a broad risk-off regime.

### 6. Events / information context

- Earnings date proximity.
- Earnings surprise and revisions.
- Material company events.
- News sentiment with source quality and freshness.
- Analyst revisions as context, not unquestioned truth.

### 7. Fundamentals for Investor

Investor evidence is intentionally different from Trader evidence:
- Revenue/EPS growth.
- Free cash flow.
- Margins.
- Debt/liquidity.
- ROIC/capital efficiency.
- Valuation vs own history and peers.
- EPS/revenue revisions.
- Quality and competitive durability proxies.
- Long-term relative strength as supporting context, not the core thesis.

## Strategy-specific logic

### Trader
Horizon: minutes to days.

Primary families:
- Trend.
- Momentum.
- Participation.
- Volatility context.
- Market/sector context.
- Event risk.

### Swing

Horizon:

**Days to weeks.**

Current release:

**v0.11.0 — Swing Strategy Brain**

Status:

**Release acceptance complete / Batches 1–10 implemented and validated.**

The validated Swing backend and attribution contract are integrated into the visible Strategy Summary. Batch 9B adds presentation-only Swing Decision Helpers; Batch 10 adds release-state coverage and recommendation-state clarity; Investor remains Coming Soon. v0.11.0 release acceptance passed on 2026-08-31.

Detailed evidence, capability and acceptance contract:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

Swing is not Trader logic running on slower candles.

### Approved Swing timeframe hierarchy

Default:

- 1D primary.
- 1W confirmation.
- 1M regime.

Alternate:

- 4H primary.
- 1D confirmation.
- 1W regime.

### Primary Swing analytical areas

- Multi-timeframe trend alignment.
- Trend structure.
- Momentum.
- Support/resistance.
- Breakout/breakdown structure.
- Participation and volume confirmation.
- Relative strength.
- Market and sector regime.
- Market breadth.
- Volatility.
- Entry-quality / price-stretch context.
- Reliable/material news context.
- Scheduled event risk.
- Strategy-specific Historical Setup Validation.

### Evidence applicability rule

No Trader evidence provider is automatically enabled for Swing.

Every existing evidence provider and capability requires an explicit decision covering:

- Whether Swing should use it.
- Why it matters.
- Correct timeframe/lookback.
- Calculation/threshold changes.
- Direction impact.
- Confidence impact.
- Risk or entry-quality impact.
- Evidence-family relationship.
- BUY/SELL behavior.
- Human-readable presentation.
- Individual info/explainability path.
- Attribution behavior.
- Limitations.

### Current approved evidence decisions

- Candle Trend — reuse with Swing calibration.
- EMA Structure — reuse with Swing calibration.
- Multi-Timeframe Trend — core Swing evidence.
- RSI — reuse with trend/regime-aware Swing interpretation.
- MACD Momentum — reuse with Swing calibration.
- Relative Volume — conditional reuse; 4H must not fabricate same-time-of-day normalization.
- Volume Confirmation — reuse with Swing calibration.
- Current analysis-window VWAP Position — excluded from initial Swing scoring.
- Support & Resistance — core Swing evidence with confirmation-aware semantics.
- Price Extension — primarily entry-quality/confidence/risk context; must not automatically claim reversal.
- Market & Sector Context / Relative Strength — core Swing evidence.
- Market Breadth — reused within Market Context.
- News Sentiment — reuse with Swing-specific freshness/materiality.
- Event Risk — confidence/risk-only; maximum 12-point penalty and no positive bonus.
- Stock DNA — core contextual input and must become strategy-aware.
- Historical Setup Validation — confidence-only, strategy/timeframe-specific and bounded to ±8 points.

### Current v0.11 implementation checkpoint

Completed through Batch 8:
- Strategy-aware evidence policy and execution gates.
- Swing 1D -> 1W -> 1M and 4H -> 1D -> 1W timeframe orchestration.
- Strategy-calibrated Trend, Momentum, Participation, Price Structure, Volatility/Entry Quality, Market Context and Sentiment evidence.
- Stock DNA contextual adjustment.
- Event Risk confidence-only adjustment.
- Historical Setup Validation strategy/timeframe calibration.
- Swing-specific recommendation decision policy.
- Swing recommendation backend activation.
- Strategy-aware recommendation-controller execution.
- Independent Trader and Swing dashboard recommendation-state orchestration.
- Family-level post-cap direction attribution.
- Provider-to-family signed direction reconciliation.
- Separate evidence-confidence attribution.
- Explicit semantic confidence-modifier sources.
- Separate Event Risk and Historical Validation confidence-only point adjustments.
- User-facing attribution MetricExplainability catalog.
- Individual info paths for family direction, family confidence, provider direction, provider confidence and confidence-calculation components.
- Provider recommendation percentages intentionally suppressed where mathematically misleading.
- Investor recommendation generation remains deferred.
- Current analysis-window VWAP remains excluded from Swing.
- Family de-duplication boundaries remain intact.
- Trader regression behavior remains protected.

Batch 8 attribution invariants:
- active family direction shares reconcile to 100%;
- family attribution uses actual effective post-cap current-case contribution;
- provider signed impacts reconcile to the capped family result;
- configured/raw provider weights are not presented as recommendation attribution;
- provider internal absolute shares are not presented as recommendation percentages;
- evidence confidence remains separate from direction;
- Event Risk remains zero-direction and maximum -12 confidence points;
- Historical Validation remains zero-direction and maximum ±8 confidence points;
- final confidence reconciles from evidence-derived confidence plus bounded external adjustments;
- every displayed attribution value has an individual info path.

Batch 8 functional validation baseline:
- Flutter analyzer clean.
- 439 recommendation subsystem tests passing.
- 512 total automated tests passing.

Batch 9A presentation-layer activation is implemented:

- Strategy Summary exposes Swing as active even before its first cached analysis result.
- The pre-analysis Swing state is shown as `Ready to analyze` with no fabricated confidence.
- Selecting Swing runs the existing Swing-specific analysis path.
- Selected-strategy Analysis Context, Recommendation, Recommendation Insight, Evidence and Risk render from the strategy-specific cached state.
- Investor remains unavailable / Coming Soon.
- No Batch 9A change modifies evidence providers, scoring weights, direction logic, family caps, attribution math, Event Risk or Historical Setup Validation.
- Decision helpers remain pending and must not create duplicate votes.

Batch 9A validation:

- 8 focused Strategy Summary/dashboard/top-level UI tests passing.
- 441 recommendation subsystem tests passing.
- 5 dashboard subsystem tests passing.
- Flutter analyzer clean.
- 514 total automated tests passing.

Batch 9B Decision Helpers are implemented:

- Swing-only `Entry Quality`, `Price Stretch` and `Structure Watch`.
- Helpers are derived from existing typed Recommendation / Price Extension / Support & Resistance outputs.
- Helpers are presentation-only and cannot feed back into consensus.
- No helper creates an evidence vote, direction points or confidence points.
- Each helper has its own reusable `MetricExplainability` info path.
- Trader remains unchanged and Investor remains unavailable.
- No scoring weights, evidence direction, family caps, attribution math, Event Risk or Historical Setup Validation behavior changed.

Batch 9B validation:

- 9 focused Decision Helper / top-level UI tests passing.
- 449 recommendation subsystem tests passing.
- Flutter analyzer clean.
- 522 total automated tests passing.
- Manual Chrome visual acceptance passed on 2026-08-31.

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

Next implementation work:

**v0.12.0 — Investor Strategy Brain after the accepted v0.11.0 checkpoint is committed, pushed and tagged.**

### Swing UI / explainability rules

Every Swing card, evidence item, metric, decision helper and recommendation input must be understandable in plain human language.

Every individual analytical input/value requires its own visible info/explainability path.

The normal UI should show the human meaning first and technical details second.

Direction attribution must reconcile to **100%** of active effective directional influence after evidence-family de-duplication and caps.

Provider attribution must reconcile to the capped family contribution.

Confidence attribution remains separate from direction attribution.

Confidence-only modifiers such as Event Risk and Historical Setup Validation remain explicit bounded point adjustments rather than fake percentages.

Decision helpers may summarize already-counted evidence but must not create another independent vote.

### Investor
Horizon: months to years.

Primary families:
- Growth.
- Profitability/quality.
- Financial strength.
- Valuation.
- Revisions.
- Competitive/industry context.
- Long-term market/technical context.

## v0.12 Investor Strategy Brain

Status: **Batch 4 Valuation implemented and validated.**

Investor horizon: months to years.

Core proposed families:
- Growth
- Profitability & Quality
- Financial Strength
- Valuation
- Revisions
- Competitive Durability
- Capital Allocation & Dilution

Context/timing:
- Long-Term Market Context
- Global Market & Macro Context
- Ownership & Positioning
- Long-Term Technical Context
- persistent/material information context

The existing `EvidenceFamily.fundamentals` placeholder must be expanded so independent long-term economic questions are not incorrectly de-duplicated into one vote.

Global market context must be measurable through observable regimes and stock-specific sensitivity. `Market Expectations` is a zero-vote helper derived from existing evidence.

Detailed scope: `docs/INVESTOR_STRATEGY_BRAIN_V0_12.md`.

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

## Solid vs volatile stock logic

A universal RSI/ATR/volume threshold is not enough.

The planned Stock DNA model separates:

Structural profile:
- What is normal for this stock over months/years?

Current regime:
- What is unusual right now relative to that normal profile?

Example:
- A 3% daily move may be exceptional for a historically steady stock but ordinary for a high-volatility small cap.
- RSI 75 may be a meaningful stretch in a mean-reverting stock but can persist during a strong momentum regime.
- 1.8x volume may be highly unusual for one stock and routine around recurring events for another.

The brain therefore uses percentiles/relative baselines and changes evidence weights according to structural profile + current regime.

## Validation before self-improving weights

TradePilot AI must not “learn” by repeatedly fitting the same history.

Before historical performance can modify live weights:
- Define the signal before evaluation.
- Use separate training and validation windows.
- Use walk-forward testing.
- Track out-of-sample performance.
- Penalize small samples.
- Track regime dependence.
- Avoid promoting correlated signals as independent discoveries.
- Preserve deterministic audit trails for every weight change.

## Release sequence

### v0.5 — Strategy-Aware Consensus Engine
Family de-duplication, conflict/agreement, direction vs confidence, explicit strategy context.

### v0.6 — Historical Context / Stock DNA
Long-term baselines, structural volatility, same-time volume foundation, current-vs-normal regime.

### v0.7 — Multi-Timeframe + Market Context Intelligence
Trader timeframe hierarchy, higher-timeframe alignment, stock-vs-market and stock-vs-sector relative strength, and Market Context evidence.

### v0.8 — Advanced Trader Evidence
EMA Structure, MACD Momentum, Volume Confirmation, analysis-window VWAP, ATR-normalized support/resistance and Price Extension with explicit family de-duplication and grouped evidence presentation.

ADX/Bollinger-style additions remain deferred until historical validation demonstrates incremental value beyond existing trend-efficiency and volatility context.

### v0.9 — Historical Setup Validation
Current setup fingerprint, similarity-weighted historical analogs, matched outcomes versus a control baseline, effective sample size, excursion statistics and a bounded confidence-only overlay. Development starts with a synthetic provider behind a replaceable interface; real performance claims are forbidden until real historical data is connected and validated out of sample.

### v0.10 — Market / Sector / Event Context
Market breadth participation, scheduled earnings/macro event risk and reliability-weighted news sentiment. Market Breadth remains inside the Market Context family; Event Risk is a confidence-only overlay; News Sentiment is a capped Sentiment family. Development uses a synthetic provider until licensed live data is connected.

### v0.10.1 — Explainability & Bidirectional Audit
Reusable explainability contracts, explicit semantic roles, individual Analysis Context explainability, supportive/opposing interpretation rules, confidence-only modifier boundaries and automated architecture invariants.

Completed safeguards include:
- Complete explainability metadata for every production evidence kind.
- Individual explainability for all seven Trader Analysis Context metrics.
- Directional/evaluative, confidence/risk-only and context/configuration semantic roles.
- Event Risk confidence-only behavior with a hard maximum 12-point penalty and no positive bonus.
- Historical Setup Validation confidence-only behavior with a hard ±8-point adjustment boundary.
- Evidence-family de-duplication and direction/confidence separation preserved.
- BUY/SELL provider regression coverage preserved.

### v0.11.0 — Swing Strategy Brain

Activate Swing as TradePilot AI's second real strategy.

Includes:

- Strategy-aware analysis/evidence policy.
- Swing-specific provider applicability.
- Swing-specific provider calibration.
- Swing timeframe/context orchestration.
- Strategy-aware Stock DNA adjustment.
- Swing-specific Event Risk relevance.
- Swing-specific Historical Setup Validation horizon.
- Swing recommendation policy.
- Reconciled direction attribution.
- Separate confidence attribution.
- Human-readable Swing cards and decision helpers.
- Individual info paths for every user-facing analytical input.
- BUY/SELL parity and regression protection.

### v0.12.0 — Investor Strategy Brain

Introduce the dedicated long-horizon Investor engine.

Planned analytical families include:

- Growth.
- Profitability / Quality.
- Financial Strength.
- Valuation.
- Revisions.
- Competitive / industry context.
- Long-term market and technical context.

Investor must use strategy-specific fundamental logic rather than reusing Swing or Trader semantics.

### v1.0.0 — Validated Multi-Strategy Milestone

TradePilot AI reaches the v1.0.0 strategy milestone when:

- Trader is implemented and validated.
- Swing is implemented and validated.
- Investor is implemented and validated.
- Each strategy has independent horizon-appropriate evidence and recommendation logic.
- Strategy Summary cleanly switches between real strategy recommendations.
- Explainability, attribution, BUY/SELL parity and data-honesty rules remain consistent across strategies.

### v1.x — Historical Calibration + AI Analyst
Replace development historical analogs with real setup/outcome data, add walk-forward/out-of-sample calibration, “what would change this recommendation?”, and AI explanations grounded only in deterministic evidence plus validated history.
