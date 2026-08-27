# TradePilot AI — v0.11.0 Swing Strategy Brain

Status: Implementation in progress — Batches 0-5 complete
Release: v0.11.0
Baseline: v0.10.1
Baseline release commit: c53ad00
Last implementation checkpoint: 2026-08-27

## 1. Purpose

v0.11.0 activates Swing as TradePilot AI's second fully implemented strategy.

Swing is not Trader logic running on slower candles.

Swing must have strategy-specific:

- Evidence applicability.
- Evidence parameters.
- Timeframe policy.
- Lookbacks.
- Thresholds.
- Context weighting.
- Direction logic.
- Confidence logic.
- Historical validation horizon.
- Event-risk horizon.
- Recommendation thresholds where justified.
- Explainability.
- User-facing decision helpers.

Target Swing horizon:

- Days to weeks.

Initial supported Swing timeframe plans already present in the architecture:

- Default: 1D primary -> 1W confirmation -> 1M regime.
- Alternate: 4H primary -> 1D confirmation -> 1W regime.

The implementation must preserve Trader behavior unless an explicitly shared architecture improvement is proven safe by regression tests.

---

## 2. Permanent v0.11.0 design rules

### 2.1 Evidence-by-evidence audit

No existing Trader capability is automatically enabled for Swing.

Every evidence provider, context input, risk modifier, historical feature and recommendation helper must be classified as one of:

- Reuse unchanged.
- Reuse with Swing calibration.
- Swing context/confidence-only.
- Replace with Swing-specific semantics.
- Exclude from Swing.
- Defer until required data quality exists.

For every capability the implementation must document:

1. Why Swing should or should not use it.
2. The correct Swing timeframe or lookback.
3. Its calculation.
4. Its semantic role.
5. How it affects direction.
6. How it affects confidence.
7. How it affects risk or entry quality.
8. Its family/de-duplication relationship.
9. BUY and SELL interpretation.
10. Limitations.
11. User-facing wording.
12. Info/explainability behavior.

### 2.2 Human-readable UI

Every Swing card, evidence item, metric, decision helper and recommendation component must be understandable without knowledge of the internal scoring engine.

Main UI wording must favor human interpretation.

Preferred pattern:

- Human conclusion first.
- Important quantitative value second.
- Detailed technical explanation behind the info path.

Example:

Preferred:
"Price is stretched above its recent trend"

Technical detail:
"+1.8 ATR above EMA equilibrium"

Avoid presenting unexplained values such as:

- "Extension 1.8"
- "Momentum 0.63"
- "Alignment 74"
- "Structure score -0.42"

### 2.3 Individual info path

Every individual user-facing Swing input/value must have its own visible info affordance.

The preferred affordance is a small info icon.

The explanation must cover, where applicable:

- What it means.
- How it is calculated.
- Why it matters specifically for Swing.
- Supportive interpretation.
- Opposing interpretation.
- Neutral interpretation.
- Direction impact.
- Confidence impact.
- Risk/entry-quality impact.
- Family de-duplication implications.
- Important limitations.

A card-level general information dialog does not replace the requirement for individual metric explanations.

### 2.4 Attribution and percentages

TradePilot AI must expose how much each criterion actually influenced the result.

Direction and confidence attribution are separate systems.

#### Direction attribution

The final active directional basis must reconcile to 100%.

The displayed percentage is not a decorative fixed indicator weight.

It must be calculated from the same effective evidence math used by the recommendation engine after:

- Provider reliability.
- Strategy-specific weighting.
- Contextual adjustment.
- Signal magnitude.
- Evidence-family aggregation.
- Family caps.
- Correlation de-duplication.

Family directional shares must reconcile to 100% of the active directional basis.

Provider shares shown inside a family must reconcile to that family's capped contribution.

Each contribution must indicate whether it:

- Supports the final direction.
- Opposes the final direction.

#### Confidence attribution

Confidence contribution must remain separate from directional influence.

Evidence-derived confidence must explain:

- Evidence coverage.
- Reliability.
- Agreement.
- Conflict.
- Independent family coverage.
- Family confidence contribution.

Confidence-only modifiers must not be falsely converted into independent evidence percentages.

Examples:

- Event Risk: "-6 confidence points".
- Historical Setup Validation: "+4 confidence points".

Final confidence should conceptually reconcile as:

Evidence-derived confidence
+/- explicit bounded modifiers
= Final confidence

Every displayed percentage or point adjustment requires an info path explaining its calculation and limitations.

### 2.5 No fake precision

A criterion must not be described as "30% of the recommendation" merely because its configured base weight is 0.30.

Displayed attribution percentages must represent actual effective contribution for the current recommendation.

Configured strategy weights and maximum family influence may be shown separately in technical detail if useful.

### 2.6 BUY / SELL parity

Every directional Swing capability must support bullish and bearish interpretation where mathematically meaningful.

Do not design a feature that enriches BUY while providing a weaker SELL implementation.

Neutral/unavailable states are valid and preferable to manufactured direction.

---

## 3. Swing evidence applicability matrix

### 3.1 Trend family

#### Candle Trend

Swing decision:
Reuse with Swing calibration.

Why it matters:
Swing positions depend on persistent multi-session price direction, but a fixed raw percentage change across the entire available snapshot is not a sufficiently robust Swing definition.

Swing direction role:
Directional/evaluative.

Bullish:
Persistent upward price structure over the Swing analysis window.

Bearish:
Persistent downward price structure over the Swing analysis window.

Neutral:
Low directional efficiency, insufficient movement or conflicting structure.

Required v0.11 change:

- Remove Trader-specific fixed-move assumptions from shared behavior.
- Use strategy-specific lookback.
- Prefer volatility-normalized or stock-context-aware strength over universal raw percentage thresholds.
- Preserve Trend-family aggregation.

Confidence:
Trend persistence and reliability may strengthen confidence through the Trend family.

Human UI:
"Recent price trend: Rising / Falling / Mixed"

Info:
Explain lookback, price change, normalization, trend quality, direction effect, confidence effect and limitations.

#### EMA Structure

Swing decision:
Reuse with Swing calibration.

Why it matters:
Moving-average structure helps determine whether current Swing price action agrees with the intermediate trend.

Swing direction role:
Directional/evaluative.

Required v0.11 change:

- EMA periods must come from Swing strategy policy rather than universal provider assumptions.
- Exact periods must be justified during implementation audit.
- EMA evidence remains inside Trend.
- Do not count EMA Structure independently from Candle Trend and Multi-Timeframe Trend.

Human UI:
"Trend structure: Bullish / Bearish / Mixed"

Info:
Show which averages are used, why those periods suit Swing, price relationship, effect and lag limitations.

#### Multi-Timeframe Trend

Swing decision:
Core Swing evidence.

Why it matters:
Swing analysis depends heavily on agreement between the trade timeframe and broader trend.

Primary supported plans:

- 1D -> 1W -> 1M.
- 4H -> 1D -> 1W.

Swing direction role:
Directional/evaluative.

Required v0.11 change:

- Remove Trader-specific wording/assumptions.
- Make interpretation explicitly strategy-aware.
- Determine Swing-specific role weights for primary, confirmation and regime timeframes.
- Higher timeframes remain part of one Trend family, not independent votes.

Human UI:
"Timeframes: Aligned bullish / Aligned bearish / Mixed"

Info:
Explain each timeframe role and how disagreement affects direction/confidence.

---

## 3.2 Momentum family

#### RSI

Swing decision:
Reuse with materially different Swing interpretation.

Why it matters:
RSI describes momentum and stretch, but overbought/oversold alone must not automatically become reversal evidence.

Important Swing principle:
Strong trends can remain overbought or oversold for extended periods.

Swing direction role:
Directional/evaluative, but regime-aware.

Required v0.11 change:

- Do not use simple RSI > 70 = bearish and RSI < 30 = bullish logic for Swing.
- Interpret RSI together with current trend/regime.
- Consider whether RSI confirms momentum, indicates healthy pullback conditions, shows divergence, or signals excessive stretch.
- Thresholds may adapt to Stock DNA and trend regime.
- Preserve Momentum-family aggregation with MACD.

Examples:

Bullish-supportive cases may include:
- RSI recovering from a pullback while broader Swing trend remains bullish.
- RSI holding a bullish trend range.
- Bullish momentum improvement with supportive price structure.

Bearish-supportive cases may include:
- RSI weakening during a bearish Swing trend.
- Failure in a bearish trend range.
- Bearish momentum deterioration confirmed by price structure.

Extreme RSI alone:
Should primarily create caution/entry-quality context unless reversal evidence is independently confirmed.

Human UI:
"Momentum: Strong / Improving / Weakening / Stretched"

Info:
Explain RSI number, trend regime, why 70/30 are not automatic Buy/Sell rules, and its exact direction/confidence impact.

#### MACD Momentum

Swing decision:
Core/reused with Swing calibration.

Why it matters:
MACD measures trend momentum and is naturally suited to multi-session Swing analysis.

Swing direction role:
Directional/evaluative.

Required v0.11 change:

- Validate Swing periods and signal interpretation.
- Consider MACD position relative to zero, signal-line relationship and momentum transition.
- Avoid scoring histogram magnitude alone as the full signal.
- Preserve Momentum-family de-duplication with RSI.

Human UI:
"Momentum trend: Strengthening / Weakening / Turning"

Info:
Explain MACD line, signal line, zero-line context, direction/confidence effect and whipsaw limitation.

---

## 3.3 Participation family

#### Relative Volume

Swing decision:
Conditional reuse.

1D Swing:
Meaningful when current daily volume is compared with comparable daily history.

4H Swing:
Must not blindly use generic recent-bar RVOL because time-of-day effects can distort comparison.

Swing semantic role:
Directional confirmation.

Required v0.11 change:

- 1D plan may use daily relative volume.
- 4H plan requires either comparable-session normalization or reduced/unavailable reliability.
- Do not fabricate same-time-of-day history that the provider does not possess.

Direction:
High volume confirms the direction of meaningful price action.

Low volume:
Usually weakens confirmation; it should not automatically create the opposite direction.

Human UI:
"Participation: Strong / Normal / Weak"

Info:
Explain baseline, multiplier, price-direction relationship and data limitations.

#### Volume Confirmation

Swing decision:
Reuse with Swing calibration.

Why it matters:
Expansion or contraction in participation can confirm breakouts, breakdowns and multi-day trends.

Swing role:
Directional/evaluative confirmation.

Required v0.11 change:

- Replace universal small fixed price-move significance with volatility-aware significance.
- Evaluate volume change together with meaningful Swing price movement.
- Preserve Participation-family de-duplication with Relative Volume.

Human UI:
"Volume confirms the move / Volume does not confirm the move"

Info:
Explain price move, volume change, baseline and whether it supports/opposes current direction.

---

## 3.4 Price Structure family

#### VWAP Position

Swing decision:
Exclude the current provider from initial Swing scoring.

Why:
The current implementation is analysis-window/session-style VWAP and is semantically oriented toward intraday analysis.

Do not present it as valid daily Swing evidence merely by changing candle duration.

Potential future Swing replacement:
Anchored VWAP from a meaningful structural anchor such as:

- Major swing low.
- Major swing high.
- Breakout.
- Gap.
- Earnings/news event.

Anchored VWAP requires a separate design and must not be introduced in v0.11 unless data and anchor-selection logic are explicitly approved.

Current Swing direction/confidence contribution:
0.

UI:
Do not display current VWAP Position as active Swing evidence.

Explainability:
If unavailable/excluded is surfaced, explain why the current VWAP definition is not applicable to Swing.

#### Support & Resistance

Swing decision:
Core Swing evidence, recalibrated.

Why it matters:
Multi-day entries and exits are strongly influenced by nearby structural levels, breakout behavior and failed breaks.

Swing role:
Directional/evaluative plus entry/risk context.

Required v0.11 change:

- Use Swing-appropriate structure lookback.
- Preserve ATR/volatility normalization.
- Do not assume "near resistance = bearish" or "near support = bullish" without confirmation.
- Proximity alone is primarily entry/risk context.
- Confirmed hold/rejection/breakout/breakdown may create direction evidence.

Bullish examples:
- Confirmed breakout above resistance.
- Support hold with bullish confirmation.
- Successful retest after breakout.

Bearish examples:
- Confirmed breakdown below support.
- Resistance rejection with bearish confirmation.
- Failed bullish breakout.

Human UI:
"Price structure: Breakout / At support / Near resistance / Breakdown / Between levels"

Info:
Explain detected levels, ATR-normalized distance, confirmation and direction/confidence effects.

---

## 3.5 Volatility family

#### Price Extension

Swing decision:
Reuse with changed role emphasis.

Why:
A stock can be strongly bullish but too extended to offer a high-quality Swing entry.

Swing role:
Primarily entry-quality/confidence/risk context.
It should not independently claim the opposite trend has begun.

Required v0.11 change:

- Separate "direction remains bullish/bearish" from "entry is stretched".
- Use Swing-appropriate equilibrium/reference period.
- Continue volatility normalization.
- Consider Stock DNA/regime.

Example:
Bullish trend + very high positive extension:
Direction may remain bullish.
Confidence in chasing a new BUY entry may decrease.

Bearish trend + very large negative extension:
Direction may remain bearish.
Confidence in chasing a new SELL entry may decrease.

Human UI:
"Entry stretch: Normal / Extended / Very extended"

Info:
Explain ATR normalization, reference trend, why extension affects entry quality and why it does not automatically reverse direction.

---

## 3.6 Market Context family

#### Market & Sector Context / Relative Strength

Swing decision:
Core Swing evidence.

Why:
A days-to-weeks move is meaningfully affected by broad-market regime, sector trend and stock leadership/weakness.

Swing role:
Directional/evaluative.

Required v0.11 change:

- Use Swing-relevant observation periods.
- Stock-vs-market and stock-vs-sector relative strength should reflect the Swing horizon.
- Market and sector direction should be evaluated over confirmation/regime windows.
- Preserve Market Context family aggregation.

Bullish:
Stock leadership with supportive or improving market/sector environment.

Bearish:
Stock weakness with deteriorating market/sector context.

Mixed:
Strong stock against weak market or weak stock against strong market should expose conflict rather than force certainty.

Human UI:
"Market backdrop: Supportive / Mixed / Challenging"
"Relative strength: Leading / In line / Lagging"

Each metric requires its own info path.

#### Market Breadth

Swing decision:
Reuse; likely important.

Why:
Broad participation matters for sustainability of multi-day market moves.

Swing role:
Directional/evaluative inside Market Context.

Required v0.11 change:

- Confirm existing breadth components are appropriate for Swing horizon.
- Preserve family de-duplication with Market & Sector Context.
- Do not create a second independent market vote.

Human UI:
"Market participation: Broad / Mixed / Narrow"

Info:
Explain advancers, medium-term participation, sector participation, volatility pressure and synthetic-data limitation.

---

## 3.7 Sentiment family

#### News Sentiment

Swing decision:
Reuse with strategy-specific freshness/materiality policy.

Why:
A material company development can influence a stock for several trading sessions.

Swing role:
Directional/evaluative when reliability and materiality are sufficient.

Required v0.11 change:

- Swing news horizon may be longer than Trader horizon.
- Freshness decay must be strategy-specific.
- Materiality remains important.
- Source diversity remains mandatory.
- Repeated headlines must not multiply evidence.

Bullish:
Reliable, material positive developments.

Bearish:
Reliable, material negative developments.

Neutral/unavailable:
Mixed, stale, weak or insufficiently diverse coverage.

Human UI:
"News context: Positive / Negative / Mixed / Limited data"

Info:
Explain source count, freshness, materiality, sentiment and current synthetic-data limitation.

---

## 4. Confidence-only and contextual capabilities

### 4.1 Event Risk

Swing decision:
Core confidence/risk-only capability.

Why:
A scheduled catalyst several days away can occur inside a normal Swing holding window.

Swing direction:
None.

Confidence:
May reduce final confidence only.

Permanent cap:
Maximum -12 confidence points.

Required v0.11 change:

- Event relevance window must become strategy-specific.
- Swing must consider whether earnings/macro events fall inside or near the expected Swing horizon.
- Never create a confidence bonus.
- Never create or flip Buy/Sell direction.

Human UI:
"Upcoming event risk: Low / Moderate / High"

Info:
Explain event, timing, Swing relevance, penalty and 12-point cap.

### 4.2 Stock DNA

Swing decision:
Core contextual capability.

Why:
The existing one-year daily baseline is naturally relevant to days-to-weeks analysis.

Swing role:
Contextual adjustment of thresholds, reliability and evidence weight.

Required v0.11 change:

- ContextualEvidenceAdjuster must become strategy-aware.
- Trader-specific intraday assumptions cannot be reused automatically.
- Structural profile and current volatility regime remain separate.
- Swing may place greater value on daily trend persistence, volatility percentile and historical volume behavior.

Direction:
Stock DNA should normally modify interpretation/weight rather than create standalone direction.

Human UI:
Plain-English stock behavior summary.

Each individual Stock DNA metric must retain its own info path.

### 4.3 Historical Setup Validation

Swing decision:
Core confidence-only validation.

Why:
Historical analogs must be compared on the same strategy horizon.

Swing direction:
None.

Confidence:
Maximum +/-8 points.

Required v0.11 change:

- Swing fingerprints must include Swing strategy/timeframe.
- Swing outcomes must use Swing-specific forward outcome windows.
- Trader and Swing outcomes must never be pooled as equivalent observations.
- Positive credit still requires adequate sample/reliability and performance above both 50% directional follow-through and the same-stock context baseline.
- Current synthetic history cannot be described as real performance evidence.

Human UI:
"Similar Swing setups: Supportive / Mixed / Opposing / Not enough history"

Info:
Explain sample size, match quality, follow-through, baseline difference, +/-8 bound and synthetic limitation.

---

## 5. Recommendation and consensus policy

### 5.1 Shared Consensus Engine

Preferred decision:
Reuse the shared family-level Consensus Engine.

Do not duplicate the consensus engine for Swing unless a mathematically necessary difference is identified.

Permanent behavior:

- Correlated providers aggregate within evidence families.
- Family caps prevent duplicate influence.
- Direction and confidence remain separate.
- Provider attribution reconciles to family contribution.

### 5.2 Strategy-aware evidence policy

v0.11 must introduce a strategy-aware policy layer.

Conceptual flow:

Strategy
-> Strategy Analysis Policy
-> Provider applicability
-> Strategy parameters/lookbacks
-> Strategy base reliability/weight
-> Evidence provider
-> Strategy-aware contextual adjustment
-> Family aggregation
-> Consensus
-> Strategy recommendation policy

The policy must make it possible to specify per strategy:

- Provider enabled/disabled state.
- Calculation parameters.
- Lookback.
- Threshold model.
- Base reliability/weight.
- Semantic role.
- Maximum family influence where required.

Avoid creating duplicated provider classes solely because the strategy changes.

### 5.3 Swing recommendation thresholds

Current Trader recommendation thresholds must not automatically become Swing thresholds.

v0.11 must audit:

- Strong Buy threshold.
- Buy threshold.
- Hold/Wait zone.
- Sell threshold.
- Strong Sell threshold.
- Minimum confidence requirement.

Rules:

- BUY and SELL thresholds must remain symmetric unless there is statistically justified evidence otherwise.
- Thresholds must not be tuned against synthetic historical outcomes and called optimized.
- Initial Swing thresholds must be documented as deterministic policy assumptions until real out-of-sample calibration exists.

---

## 6. Attribution acceptance criteria

Every Swing recommendation must expose actual current-case attribution.

### Direction basis

The active directional contribution must reconcile to 100%.

Example structure only:

Trend                 supportive XX%
Momentum              supportive/opposing XX%
Participation         supportive/opposing XX%
Price Structure       supportive/opposing XX%
Market Context         supportive/opposing XX%
Sentiment              supportive/opposing XX%

Total active directional basis = 100%.

The numbers must be calculated dynamically from actual effective contributions.

A family with no active directional contribution is excluded from the 100% denominator rather than receiving a decorative percentage.

### Provider detail

When a family is expanded:

- Provider shares must reconcile to the family's capped contribution.
- Correlated providers cannot appear as independent uncapped percentages.

Example:

Trend family = 32% of direction basis

Inside Trend:
- Multi-Timeframe Trend = effective share of Trend family.
- EMA Structure = effective share.
- Candle Trend = effective share.

Provider detail must reconcile to the 32% family total.

### Confidence

Evidence-derived confidence must remain conceptually separate.

The UI must distinguish:

- Evidence confidence.
- Event Risk point adjustment.
- Historical Validation point adjustment.
- Final confidence.

Do not normalize Event Risk or Historical Validation into the direction-attribution 100%.

---

## 7. Swing Analysis Context

Swing must have a strategy-specific Analysis Context card directly beneath Strategy Summary.

Minimum proposed metrics:

- Primary Analysis Interval.
- Confirmation Interval.
- Broader Regime Interval.
- Timeframe Alignment.
- Market Environment.
- Market Breadth.
- Relative Strength.
- Event Risk.
- News Sentiment.

The exact final visible set must be reviewed for simplicity.

Each visible metric requires:

- Human-readable value.
- Individual info icon.
- Swing-specific explanation.
- Direction/confidence/risk role.
- Limitations.

Do not overload the main card with internal engine terminology.

---

## 8. Swing decision helpers

Decision helpers are allowed only when they simplify real underlying evidence.

Potential helpers include:

- Trend quality.
- Entry quality.
- Price stretch.
- Nearby structure risk.
- Event risk.
- Evidence conflict.

A helper must never become an unexplained proprietary score.

Example:

Preferred:
"Entry quality: Caution — price is extended and close to resistance"

Avoid:
"Entry Score: 63"

Every helper requires an info path explaining:

- Inputs.
- Calculation/logic.
- Why it matters.
- Whether it affects direction, confidence or risk.
- Limitations.

If a helper is derived from evidence already counted in the Consensus Engine, the helper itself must not create another vote.

---

## 9. Explainability requirements

All v0.10.1 explainability invariants remain mandatory.

Every new Swing metric must use the reusable explainability architecture.

Directional/evaluative:
Requires supportive and opposing interpretation where meaningful.

Confidence/risk-only:
Requires explicit bounded impact and cannot create direction.

Context/configuration:
Must not manufacture directional meaning.

Main UI:
Simple human language.

Detailed info:
Technical/statistical explanation.

---

## 10. Data honesty

Current development limitations remain active.

Do not present as authoritative live intelligence:

- Mock market data.
- Synthetic external context.
- Synthetic historical outcomes.
- Mock news sentiment.
- Mock market breadth.
- Mock event timing.

Same-time-of-day RVOL must not be fabricated.

True session VWAP must not be fabricated.

Real Swing performance must not be claimed until authoritative historical data and out-of-sample validation exist.

---

## 11. Features explicitly deferred from initial v0.11

Unless the evidence audit proves they are necessary, do not add merely because they are common indicators:

- ADX.
- Bollinger Bands.
- Stochastic.
- Stochastic RSI.
- MFI.
- Ichimoku.
- Additional moving-average variants.

Reason:
TradePilot AI already has overlapping evidence families. New indicators must demonstrate incremental information rather than duplicate existing signals.

Also deferred:

- Swing Anchored VWAP implementation.
- Real historical performance optimization.
- Live strategy-weight self-learning.
- Investor fundamentals.
- AI-generated recommendation logic.

Anchored VWAP may be separately proposed if the current Swing Price Structure family is shown to have a real information gap.

---

## 12. v0.11 implementation sequence

### Batch 0
Scope, evidence audit and acceptance criteria.

### Batch 1
Strategy-aware analysis/evidence policy foundation.

No Swing UI activation yet.

### Batch 2
Swing timeframe/context orchestration.

Validate:
- 1D -> 1W -> 1M.
- 4H -> 1D -> 1W.

### Batch 3
Trend and Momentum Swing calibration.

Status:

**Completed and regression-validated on 2026-08-26.**

Implemented:
- Candle Trend — strategy-specific recent-window and volatility-normalized Swing calibration.
- EMA Structure — Swing 20/50 EMA structure with slope, persistence and ATR-normalized separation.
- Multi-Timeframe Trend — primary-anchored Swing direction using the approved timeframe-role policy.
- RSI — trend-context-aware Swing momentum; overbought/oversold no longer automatically creates SELL/BUY direction.
- MACD Momentum — Swing momentum phase, recent crossover, zero-line context and ATR-normalized histogram interpretation.

Invariant boundary:
- Candle Trend, EMA Structure and Multi-Timeframe Trend remain de-duplicated inside the Trend family.
- RSI and MACD Momentum remain de-duplicated inside the Momentum family.
- Trader behavior remains protected by regression tests.
- Swing recommendation generation remains inactive until later orchestration batches are complete.

### Batch 4
Participation, Price Structure and Volatility Swing calibration.

Status:

**Completed and regression-validated on 2026-08-27.**

Implemented:
- Relative Volume — 1D Swing uses valid daily history; 4H refuses fabricated same-session-position normalization.
- Volume Confirmation — volatility-aware ATR significance replaces the fixed Trader price-move gate for Swing.
- Support & Resistance — proximity alone is neutral; confirmed breakout, breakdown, hold or rejection may create direction.
- Price Extension — Swing remains directionally neutral and affects confidence, entry quality and risk only.
- Current analysis-window VWAP remains excluded from initial Swing scoring.

Invariant boundary:
- Relative Volume and Volume Confirmation share the Participation family and cannot become two independent participation votes.
- Support & Resistance remains in the Price Structure family.
- Price Extension remains in the Volatility family with exactly zero Swing directional influence.
- 4H Relative Volume does not fabricate comparable session-position history.
- Support/resistance proximity alone cannot manufacture BUY/SELL direction.
- Trader behavior remains protected by regression tests.
- Swing recommendation generation remains inactive until later orchestration batches are complete.

Functional completion validation before this documentation checkpoint:
- Flutter analyzer: clean.
- Provider suite: 113 passing tests.
- Full automated suite: 404 passing tests.

### Batch 5
Market Context, Sentiment, Stock DNA and Event Risk.

Status:

**Completed and regression-validated on 2026-08-27.**

Implemented:
- Market & Sector Context / Relative Strength — Swing uses strategy-specific confirmation/regime weighting, stock-relative leadership remains dominant, conflicting stock-vs-market context is discounted rather than forced, and missing sector data is not duplicated as fake independent evidence.
- Market Breadth — Swing recalculates breadth from advancers, medium-term participation and sector participation; elevated volatility reduces influence without manufacturing bearish direction.
- News Sentiment — Swing uses freshness, materiality, source diversity and explicit de-duplicated independent-story coverage; repeated headline count cannot multiply evidence after the minimum coverage gate is met.
- Stock DNA — strategy-aware contextual adjustment requires the daily historical baseline for Swing, is bounded to a 0.75-1.20 dynamic-weight range and changes existing evidence weight only.
- Event Risk — Swing uses strategy-specific scheduled-event relevance windows: earnings up to 14 days and high-impact macro events up to 7 days.

Invariant boundary:
- Market Context and Market Breadth remain de-duplicated inside one Market Context family.
- News Sentiment remains directional/evaluative only when freshness, materiality and independent-story quality gates are satisfied.
- Stock DNA is contextual only: it cannot create an evidence provider, create or flip BUY/SELL direction, or change evidence score/reliability.
- Event Risk remains outside directional evidence and direction attribution.
- Event Risk can only reduce final confidence, never award a positive bonus, and is hard-capped at -12 confidence points.
- Event Risk cannot change direction score or evidence-derived confidence.
- Current external market/news/event development data remains explicitly synthetic.
- Trader behavior remains protected by regression tests.
- Swing recommendation generation remains inactive until later orchestration batches are complete.

Functional completion validation before this documentation checkpoint:
- Flutter analyzer: clean.
- Provider suite: 133 passing tests.
- Full automated suite: 467 passing tests.

### Batch 6
Swing historical validation.

Implement:
- Strategy/timeframe-specific matching.
- Swing forward outcomes.
- Same-stock context baseline.
- +/-8 confidence boundary.

### Batch 7
Swing recommendation orchestration and strategy policy.

Implement:
- Swing recommendation generation.
- Recommendation thresholds.
- BUY/SELL parity.
- Conflict/Hold behavior.

### Batch 8
Attribution and explainability.

Implement:
- Direction basis reconciles to 100%.
- Provider-to-family reconciliation.
- Separate confidence attribution.
- Individual info paths.

### Batch 9
Swing UI activation and decision helpers.

Implement:
- Strategy Summary activation.
- Swing Analysis Context.
- Human-readable evidence.
- Human-readable decision helpers.
- Individual info controls.

### Batch 10
Full regression, visual acceptance, documentation and release.

---

## 13. Acceptance criteria

v0.11.0 is not complete until all of the following are true:

1. Swing produces its own real strategy recommendation.
2. Trader behavior remains regression-clean.
3. Swing is not implemented as a copy of Trader thresholds.
4. Every existing evidence provider has an explicit Swing applicability decision.
5. Every enabled Swing evidence provider has documented strategy parameters.
6. Every enabled directional capability has BUY/SELL parity where meaningful.
7. Evidence-family de-duplication remains intact.
8. Direction attribution reconciles to 100% of active directional influence.
9. Provider attribution reconciles to capped family attribution.
10. Confidence attribution remains separate from direction attribution.
11. Event Risk remains confidence-only and no worse than -12 points.
12. Historical Setup Validation remains confidence-only and within +/-8 points.
13. Current VWAP Position is not incorrectly reused as Swing evidence.
14. RSI does not automatically treat overbought as SELL or oversold as BUY in Swing.
15. Price Extension does not automatically claim trend reversal.
16. Support/resistance proximity alone is not treated as confirmed direction.
17. 4H Relative Volume does not fabricate time-of-day normalization.
18. Every Swing card is understandable in plain language.
19. Every individual Swing input/value has its own info path.
20. Every displayed percentage explains what it represents.
21. Main UI remains simple; technical complexity is behind details/info.
22. Synthetic/mock data remains explicitly identified.
23. Full Flutter analyzer is clean.
24. Full automated test suite passes.
25. Trader provider regression suite passes.
26. Swing-specific provider and orchestration tests pass.
27. Visual acceptance passes for BUY, SELL, HOLD/conflict and unavailable-data states.
28. Canonical project documentation is updated before release.
29. Release receives semantic version v0.11.0.

---

## 14. Roadmap after v0.11

Approved release sequence:

- v0.11.0 — Swing Strategy Brain.
- v0.12.0 — Investor Strategy Brain.
- v1.0.0 — validated multi-strategy milestone with Trader, Swing and Investor implemented.

Investor work must not be pulled into v0.11.0.

---

## 15. First production-code rule

Do not begin by activating Swing in the UI.

The first production-code batch must create the strategy-aware policy architecture required to safely express differences between Trader and Swing.

Only after strategy policy, evidence applicability and Swing context are validated should Swing become an active recommendation strategy.
