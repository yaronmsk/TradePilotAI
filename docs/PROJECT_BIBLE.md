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
- When evidence is inadequate or conflicted, WAIT/HOLD is preferable to false certainty.

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

**v0.11.0 active development.**

Swing has a validated strategy-specific backend and is now selectable in the visible Strategy Summary through Batch 9A. Investor remains unavailable. Remaining v0.11.0 UI work is decision-helper completion and final validation.

Swing must not be implemented as Trader logic running on slower candles.

Approved initial timeframe hierarchy:

- Default: 1D primary → 1W confirmation → 1M regime.
- Alternate: 4H primary → 1D confirmation → 1W regime.

Every existing evidence provider and capability requires an explicit Swing applicability/calibration decision.

Detailed Swing evidence and capability rules are defined in:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

### Investor
Months to years. Fundamentals, valuation, growth, quality, revisions, competitive position and long-term technical context.

Planned for v0.12.0.

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
9. v0.11.0 — Swing Strategy Brain. Active development.
10. v0.12.0 — Investor Strategy Brain.
11. v1.0.0 — Validated multi-strategy milestone with Trader, Swing and Investor implemented.
12. v1.x — Real historical setup database, walk-forward calibration and AI Analyst / Mentor grounded in deterministic analysis.

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

Decision helpers may summarize existing evidence but must not create another independent vote when derived from evidence already counted by the Consensus Engine. Batch 9A activates Swing presentation only; decision-helper implementation remains a separate Batch 9 step.

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
