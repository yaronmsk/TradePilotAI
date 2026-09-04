# TradePilot AI Project Bible

Version: 1.8
Status: Living reference

## Mission

Build an explainable, statistically grounded investment analysis platform that helps users understand evidence, probability and risk rather than pretending to predict the future.

## Permanent principles
- Never claim to predict the market.
- Every recommendation must be traceable to measurable evidence.
- Supporting and opposing evidence are both displayed.
- Direction and confidence are separate concepts.
- Confidence is earned from coverage, reliability, agreement, independence and historical validation.
- Correlated indicators must not gain artificial voting power merely because several versions of the same idea are present.
- Dynamic thresholds and stock-specific baselines are preferred to one-size-fits-all thresholds.
- Trader, Swing and Investor are separate strategies with different horizons and logic.
- Every detailed Recommendation, Recommendation Insight, Evidence, Risk and future AI explanation must explicitly belong to a strategy.
- The Strategy Summary is the master strategy selector for the detail analysis below it.
- AI explains, mentors and analyzes; deterministic engines decide.
- Business logic is independent from the visual UI.
- Current UI is provisional and can be completely redesigned later.
- Buy and Sell capabilities receive equal treatment.
- Explainability is a reusable domain contract rather than widget-specific copy.
- Every explainable metric must explicitly declare whether it is directional/evaluative, confidence/risk-only or context/configuration.
- Directional/evaluative inputs must represent supportive and opposing interpretations wherever mathematically meaningful.
- Confidence/risk-only inputs cannot manufacture Buy/Sell direction and must declare their bounded effect.
- Direction influence and confidence contribution must remain separate.
- Evidence attribution must respect evidence-family aggregation and family caps.
- Every user-facing card, evidence item, decision helper, metric, score, percentage, context value and recommendation input must be understandable in plain human language.
- Every individual user-facing analytical input/value must have its own visible info/explainability path.
- A card-level explanation does not replace individual input/value explainability.
- Main UI should present the human conclusion first and place deeper technical/statistical detail behind the info path.
- Direction attribution percentages must represent actual current-case effective influence rather than configured base weights.
- The active post-de-duplication directional basis must reconcile to 100%.
- Provider attribution shown inside an evidence family must reconcile to that family's capped contribution.
- Supportive and opposing directional influence must remain identifiable.
- Confidence attribution must remain separate from directional attribution.
- Confidence-only modifiers must be displayed as explicit bounded point adjustments rather than fake evidence percentages.
- When evidence is inadequate or conflicted, non-action states are preferable to false certainty; the UI uses `Wait for Confirmation` for developing-but-not-actionable setups and `No Clear Direction` for neutral/conflicted setups.

## Current architecture

Market data
→ Primary market snapshot / historical Stock DNA
→ Strategy-selected primary analysis interval + automatic confirmation / broader backdrop
→ Broad-market / sector relative context
→ Stock behavior profile
→ Evidence providers
→ Contextual evidence adjuster
→ Evidence report
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy-specific recommendation
→ Historical Setup Validation (bounded confidence overlay)
→ Presentation / explainability
→ Future AI Analyst / Mentor

## Current implemented evidence
- Candle Trend — Trend family
- EMA Structure — Trend family
- Multi-Timeframe Trend — Trend family (same family by design; higher timeframes cannot create duplicate independent votes)
- RSI — Momentum family
- MACD Momentum — Momentum family
- Relative Volume — Participation family
- Volume Confirmation — Participation family
- VWAP Position — Price Structure family
- Support & Resistance — Price Structure family
- Price Extension — Volatility family
- Market & Sector Context — Market Context family
- Market Breadth — Market Context family
- News Sentiment — Sentiment family

Correlated providers remain de-duplicated inside their evidence family.

Event Risk is intentionally not an evidence family. It is a confidence/risk-only modifier that cannot create Buy/Sell direction, cannot produce a positive confidence bonus and is hard-capped at a 12-point confidence penalty.

Historical Setup Validation is also not an evidence family. It is a post-consensus confidence-only overlay hard-bounded to ±8 final-confidence points.

## Current brain outputs

Internal engine outputs:
- Direction Score
- Confidence
- Bullish / bearish evidence support
- Agreement / conflict
- Evidence Coverage
- Family Coverage
- Independent Family Count
- Per-family direction summary

Default user-facing Recommendation Insight:
- Signal Strength
- Confidence
- Signal Alignment
- Plain-English `Why this confidence?` explanation

Technical metrics remain available behind `How was this calculated?` and info controls. The default UI must not expose engine jargon when a clearer investor-facing term exists.

## Current stock context / Stock DNA

Preferred baseline: one trading year of daily price and volume history. If long-history data is unavailable, the engine falls back to the short Trader snapshot rather than blocking the recommendation.

Current Stock DNA inputs:
- Typical normalized daily ATR%.
- Recent and typical annualized realized volatility.
- Current volatility percentile versus the stock's own history.
- 20D and 60D average daily volume.
- Daily-volume variability and 20D/60D volume trend.
- 20D and 60D trend efficiency.
- Short-window relative volume and trend efficiency for the active Trader analysis.

The engine separates **Stock Type** (Steady / Balanced / Volatile structural behavior) from **Volatility Now** (Calm / Normal / Elevated relative to that stock's own history). This context changes evidence weights; it does not create a Buy/Sell signal by itself.

Same-time-of-day historical RVOL is intentionally deferred until the data provider supplies real prior intraday sessions at matching clock offsets. Daily data must not be used as a fake substitute.

## Strategy model

### Trader
Minutes to days. Technical, volume, volatility, market regime and event-aware. Active.

### Swing
Days to weeks.

**v0.11.0 release acceptance complete.**

Swing has a validated strategy-specific backend, is selectable in the visible Strategy Summary, includes presentation-only Decision Helpers, and exposes typed recommendation-state reasons with human-readable non-action wording. Investor remains unavailable. v0.11.0 release acceptance passed on 2026-08-31; designated release tag: `v0.11.0`.

Swing must not be implemented as Trader logic running on slower candles.

Approved initial timeframe hierarchy:

- Default: 1D primary → 1W confirmation → 1M regime.
- Alternate: 4H primary → 1D confirmation → 1W regime.

Every existing evidence provider and capability requires an explicit Swing applicability/calibration decision.

Detailed Swing evidence and capability rules are defined in:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

### Investor
Months to years. Fundamentals, valuation, growth, quality, revisions, competitive position and long-term technical context.

v0.12.0 Batch 6 Global Market & Macro Context + Stock Sensitivity Profile is implemented and validated. Investor remains unavailable for production recommendation generation; market/macro remains contextual-only, VIX remains non-directional, and Competitive Durability remains overlap-gated from breadth pending Batch 8. Detailed contract: `docs/INVESTOR_STRATEGY_BRAIN_V0_12.md`.

Investor fundamentals are split into independent Growth, Profitability/Quality, Financial Strength, Valuation, Revisions, Competitive Durability and Capital Allocation/Dilution families. Global Market/Macro Context is measurable context based on observable regimes plus stock-specific sensitivity. `Market Expectations` is a zero-vote synthesis and cannot double-count its inputs.

The same stock may legitimately have different conclusions for all three strategies because strategy horizons, evidence applicability, parameters, context and historical-validation windows differ.

## Feature research rule

Before major features are designed:
1. Compare leading competing products using current public sources.
2. Identify what they do well.
3. Identify what TradePilot AI can make more adaptive, transparent or useful.
4. Design the architecture before coding.
5. Avoid adding a feature merely because competitors have it.

## Historical-validation discipline

When the brain begins learning from historical effectiveness:
- Separate training and validation data.
- Prefer walk-forward evaluation.
- Track out-of-sample results.
- Avoid repeatedly optimizing against the same backtest period.
- Do not promote a signal weight because of an attractive in-sample result alone.

## Development workflow

- Complete files / coherent implementation packages.
- Keep implementation packages compile-ready.
- Run dart format.
- Run flutter analyze.
- Run flutter test.
- Test the feature visually.
- Commit and push each completed release.
- Tag meaningful milestones.
- Update this Bible for major architectural decisions.

## Immediate brain roadmap
1. v0.4 — Relative Volume + short-window Stock Behavior context. Done.
2. v0.5 — Strategy-aware Consensus Engine, evidence-family de-duplication and Recommendation Insight. Done.
3. v0.6 — One-year Historical Context / Stock DNA foundation. Done.
4. v0.7 — Multi-timeframe Trader intelligence + market/sector relative strength. Done.
5. v0.8 — Advanced Trader evidence + selectable Trader primary analysis interval with strategy-specific timeframe policy. Done.
6. v0.9 — Context-matched Historical Setup Validation / similar-case confidence overlay. Done.
7. v0.10 — Broader market breadth, scheduled event risk and reliability-weighted news sentiment. Done.
8. v0.10.1 — Reusable explainability architecture, semantic roles and bidirectional/confidence-only invariants. Done.
9. v0.11.0 — Swing Strategy Brain. Release acceptance complete.
10. v0.12.0 — Investor Strategy Brain. Batch 6 Global Market & Macro Context + Stock Sensitivity Profile validated.
11. v1.0.0 — Validated multi-strategy milestone with Trader, Swing and Investor implemented.
12. v1.x — Real historical setup database, walk-forward calibration and AI Analyst / Mentor grounded in deterministic analysis.

## v0.11.0 release acceptance checkpoint

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

## UI roadmap

Current UI remains functional/provisional. A dedicated commercial look-and-feel redesign will occur after the product intelligence is sufficiently mature.


## Multi-Timeframe / Market Context

Trader context uses a hierarchy rather than equal timeframe votes. The user selects the **Primary Analysis Interval** inside Trader Analysis Context; confirmation and broader-backdrop intervals are chosen automatically so the strategy remains coherent. Current Trader choices are 1m, 5m, 15m, 30m and 1h, with 5m as the default.

Examples:
- 1m primary → 5m confirmation → 1h broader backdrop.
- 5m primary → 1h confirmation → 1d broader backdrop.
- 15m primary → 1h confirmation → 1d broader backdrop.
- 30m / 1h primary → 4h confirmation → 1d broader backdrop.

The visual Price History range remains independent. Changing 1D/5D/1M/3M/1Y does not recalculate the recommendation; changing the Primary Analysis Interval does.

Future strategy defaults are intentionally different: Swing defaults to daily analysis with weekly/monthly context; Investor defaults to weekly technical context with monthly/quarterly backdrop, while fundamentals remain the dominant Investor inputs. Investor technical timeframes are therefore secondary rather than the main recommendation driver.

Higher-timeframe trend remains part of the Trend evidence family. Market/sector relative strength is a separate Market Context family. The user-facing label is Market Environment. Strategy Summary comes before Analysis Context so the selected strategy always establishes the meaning of the detailed context below it. Context may strengthen or weaken confidence but never replaces the full deterministic evidence set.


## Advanced Trader evidence rule

v0.8 expands provider-level detail without multiplying independent confidence. Trend contains Candle Trend, EMA Structure and Multi-Timeframe Trend; Momentum contains RSI and MACD; Participation contains Relative Volume and Volume Confirmation; Price Structure contains VWAP Position and Support & Resistance; Price Extension belongs to Volatility. The default Evidence UI groups providers by evidence family and keeps provider detail expandable. A bullish trend can be opposed by extension/entry-risk evidence without claiming the trend itself has reversed.


## Recommendation attribution rule

Every strategy recommendation must explain both **direction** and **confidence** quantitatively.

Direction influence and confidence contribution are separate concepts.

### Direction attribution

Family-level direction attribution is shown first; provider-level detail remains expandable.

Displayed direction percentages must be calculated from the same effective deterministic math used to produce the recommendation after:

- Strategy-specific weighting.
- Provider reliability.
- Contextual adjustment.
- Signal magnitude.
- Evidence-family aggregation.
- Family caps.
- Correlation de-duplication.

Configured base weight is not the same thing as actual current-case influence and must not be presented as though it were.

The active directional basis must reconcile to **100%**.

A family with no active directional contribution is excluded from the 100% denominator rather than being assigned a decorative percentage.

Each active family contribution must identify whether it:

- Supports the final direction.
- Opposes the final direction.

Provider-level attribution shown inside a family must reconcile exactly to that family's capped contribution.

Correlated providers cannot gain artificial independent influence.

### Confidence attribution

Confidence attribution remains separate from directional attribution.

Evidence-derived confidence should explain, where relevant:

- Evidence coverage.
- Independent family coverage.
- Reliability.
- Agreement.
- Conflict.
- Family confidence contribution.

Confidence-only overlays must remain explicit bounded point adjustments.

Examples:

- Event Risk: negative confidence points only, maximum -12.
- Historical Setup Validation: maximum ±8 final-confidence points.

They are never normalized into the directional 100% basis.

Final confidence conceptually reconciles as:

Evidence-derived confidence
+/- bounded confidence modifiers
= Final confidence

Confidence is not a probability-of-profit guarantee.

## v0.10.1 Explainability architecture rule

`MetricExplainability` is the reusable domain contract for user-facing analytical explanation.

Every explainable metric belongs to one explicit semantic role:

### Directional / evaluative

May influence directional interpretation.

Supportive and opposing interpretations are required wherever mathematically meaningful.

Neutral/unknown interpretation should be represented where useful rather than forcing a false directional conclusion.

### Confidence / risk only

May modify confidence or risk only within an explicit boundary.

These metrics cannot create or flip Buy/Sell direction.

Current permanent bounds:

- Event Risk — maximum 12-point confidence penalty and no positive confidence bonus.
- Historical Setup Validation — maximum ±8-point final-confidence adjustment.

### Context / configuration

Explains analysis state or configuration without manufacturing bullish/bearish meaning.

Primary Analysis Interval is the current example.

### Current explainability coverage

Production evidence is covered by a central explainability catalog keyed by `EvidenceKind`.

Trader Analysis Context has individual explainability for:

- Primary Analysis Interval.
- Timeframe Alignment.
- Market Environment.
- Market Breadth.
- Relative Strength.
- Event Risk.
- News Sentiment.

Historical Setup Validation uses the same reusable explainability architecture.

Reusable explanation content exposes, where applicable:

- What the metric means.
- How it is calculated.
- Why it matters.
- Supportive interpretation.
- Opposing interpretation.
- Neutral interpretation.
- Recommendation impact.
- Explicit impact boundary.
- Limitations.

Architecture tests must fail when registered production metrics lack complete explainability metadata.

Behavioral tests must preserve semantic-role boundaries, evidence-family de-duplication, direction/confidence separation and BUY/SELL analytical parity.

## v0.11.0 Swing Strategy Brain rule

Detailed implementation contract:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

v0.11.0 activates Swing as TradePilot AI's second real strategy.

Swing is a days-to-weeks strategy and must not inherit Trader evidence semantics automatically.

Before any existing capability affects a Swing recommendation, the implementation must explicitly determine:

1. Whether Swing should use it.
2. Why it matters to Swing.
3. Correct Swing timeframe and lookback.
4. Calculation and threshold policy.
5. Direction effect.
6. Confidence effect.
7. Risk or entry-quality effect.
8. Evidence-family/de-duplication relationship.
9. BUY and SELL interpretation.
10. Human-readable presentation.
11. Individual info/explainability behavior.
12. Attribution behavior.
13. Important limitations.

### Strategy-aware policy

v0.11.0 introduced the strategy-aware analysis/evidence policy before Swing UI activation. Batch 9A now connects the validated Swing backend to Strategy Summary and the selected-strategy presentation without changing evidence math.

The policy must support per-strategy:

- Provider applicability.
- Strategy-specific parameters.
- Lookbacks.
- Thresholds.
- Base reliability/weight.
- Semantic role.
- Direction behavior.
- Confidence behavior.
- Risk / entry-quality behavior.
- Evidence-family constraints.

Shared provider implementations are preferred where the underlying calculation is genuinely reusable.

Duplicating an entire Trader provider merely to create a Swing version is not the default architecture.

### Approved initial Swing evidence decisions

- Candle Trend — reuse with Swing calibration.
- EMA Structure — reuse with Swing calibration.
- Multi-Timeframe Trend — core Swing evidence.
- RSI — reuse with materially different trend/regime-aware interpretation.
- MACD Momentum — reuse with Swing calibration.
- Relative Volume — conditional reuse; 4H must not fabricate same-time-of-day normalization.
- Volume Confirmation — reuse with Swing calibration.
- Current analysis-window VWAP Position — excluded from initial Swing scoring.
- Support & Resistance — core Swing evidence with confirmation-aware semantics.
- Price Extension — primarily entry-quality/confidence/risk context and must not automatically claim trend reversal.
- Market & Sector Context / Relative Strength — core Swing evidence.
- Market Breadth — reused inside Market Context.
- News Sentiment — reuse with Swing-specific freshness/materiality policy.
- Event Risk — confidence/risk-only with maximum 12-point penalty and no positive bonus.
- Stock DNA — core strategy context and must become strategy-aware.
- Historical Setup Validation — confidence-only, strategy/timeframe specific and bounded to ±8 points.

### Swing UI and explainability

Every Swing card, evidence item, decision helper, metric and recommendation input must remain understandable in plain language.

Every individual analytical input/value requires its own visible info/explainability path.

The main UI should describe human meaning first.

Example:

Preferred:

`Entry stretch: Extended`

with detailed ATR calculation behind info.

Avoid:

`Extension score: 1.82`

without explanation.

Decision helpers may summarize existing evidence but must not create another independent vote when derived from evidence already counted by the Consensus Engine. Batch 9B implements Swing `Entry Quality`, `Price Stretch` and `Structure Watch` as presentation-derived summaries only. They consume existing typed recommendation/evidence outputs and add zero direction points, zero confidence points and zero independent votes.

### Swing attribution

Direction attribution must reconcile to 100% of active effective directional influence after family de-duplication and caps.

Provider shares must reconcile to their family's capped contribution.

Direction attribution and confidence attribution remain separate.

Event Risk and Historical Setup Validation remain explicit bounded confidence-point adjustments rather than fake pieces of the directional 100%.

### Data honesty

Synthetic/mock data must remain explicitly identified.

Swing weights or thresholds must not be described as statistically optimized from synthetic historical outcomes.

Neutral or unavailable evidence is preferable to fabricated information.

## Historical Setup Validation rule

Historical validation is an **external validation overlay**, not another evidence family. It is derived from the same current evidence, so counting it as an independent signal would double-count the setup.

The current setup fingerprint uses strategy/timeframe, de-duplicated evidence-family direction/strength, Stock DNA, volatility regime, Market Environment and Relative Strength. Historical outcomes are then evaluated only after the setup state is fixed. Future price data must never enter the fingerprint.

The layer reports similar-case count, effective sample size, match quality, similar-setup follow-through, a context-matched same-stock follow-through baseline, Historical Difference, median forward/directional move and favorable/adverse excursion. Historical setup analogs must share the current Stock Profile as a hard eligibility rule. The same-stock baseline must share strategy, analysis interval, Stock Profile, volatility regime and Market Environment, while deliberately not requiring today's specific evidence setup. Positive historical credit is allowed only when matched follow-through exceeds both 50% and this context-matched stock baseline.

Historical validation may adjust **confidence only**, currently capped at ±8 points. It cannot alter recommendation direction by itself. Evidence/provider attribution reconciles to evidence-derived confidence; the historical adjustment is displayed separately before final confidence.

The v0.9 mock provider is explicitly synthetic development data. It validates architecture and UX, not real-world performance. Production use requires a real historical setup/outcome store plus out-of-sample/walk-forward validation before any learned calibration can influence live weights.

## Historical Validation Scoring Principle

TradePilot AI must not treat all historical measurements as equally informative. Historical setup validation prioritizes the difference versus the context-matched same-stock baseline, then uses directional follow-through, normalized outcome magnitude, and excursion quality as supporting dimensions. Statistical sample depth and match quality are reliability gates rather than additional votes. The UI must expose the configured historical weights and reliability factors so the confidence adjustment is auditable.


## Market, Event & News Context rule

Market Breadth belongs to the existing Market Context evidence family so index/sector trend and breadth cannot manufacture multiple independent market votes. News Sentiment is a separate Sentiment family but is reliability-gated by source diversity, freshness and materiality. Scheduled Event Risk is not directional evidence: earnings or high-impact macro proximity may reduce confidence within a bounded penalty but cannot create Buy/Sell direction by itself. Synthetic development context must be labeled and must never be presented as real current market/news/calendar data.
