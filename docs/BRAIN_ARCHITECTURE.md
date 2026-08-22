# TradePilot AI Brain Architecture

Version: 0.8 advanced Trader evidence + selectable analysis intervals
Status: Living design

## Core rule

A recommendation is not an indicator vote. It is a strategy-specific, context-aware conclusion built from independent evidence families whose meaning and weight change according to the stock, market regime, timeframe, data quality and investment horizon.

## Decision pipeline

Active market snapshot + fixed historical baseline
→ Historical Stock DNA + current regime
→ Evidence providers
→ Contextual evidence weighting
→ Evidence report
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy-specific recommendation
→ Deterministic explanation
→ Future AI Mentor / Analyst explanation

The Stock DNA baseline is a brain input, not a chart setting. The visual Market History range remains independent from recommendation analysis.

## Strategy ownership

Every detailed output must belong to a StrategyType:
- Trader — Hours to Days
- Swing — Days to Weeks
- Investor — Months to Years

The Strategy Summary is the master context selector. Selecting a strategy controls the Recommendation, Recommendation Insight, Evidence, Risk and future AI explanation below it.

The same stock can legitimately be:
- Sell for Trader
- Hold for Swing
- Buy for Investor

These are not contradictions because the horizons, data and decision rules differ.

## Evidence families

Evidence is grouped by the economic/market behavior it measures rather than treated as an unlimited collection of votes.

Current families:
- Trend
- Momentum
- Participation
- Price Structure
- Volatility
- Market Context

Reserved future families:
- Fundamentals
- Sentiment
- Other

Current mappings:
- Candle Trend → Trend
- EMA Structure → Trend
- Multi-Timeframe Trend → Trend
- RSI → Momentum
- MACD Momentum → Momentum
- Relative Volume → Participation
- Volume Confirmation → Participation
- VWAP Position → Price Structure
- Support & Resistance → Price Structure
- Price Extension → Volatility
- Market & Sector Context → Market Context

De-duplication example:
- Candle Trend, EMA Structure and Multi-Timeframe Trend refine one Trend conclusion rather than creating three independent votes.
- RSI and MACD refine one Momentum conclusion.
- Relative Volume and Volume Confirmation refine one Participation conclusion.
- VWAP and Support/Resistance refine one Price Structure conclusion.

## Family de-duplication rule

Inside each family:
- All usable signals influence the family's direction and strength.
- Internal agreement is measured.
- Reliability remains relevant.
- The family's final influence is capped by the strongest effective evidence weight in that family.

Therefore adding another correlated indicator can refine a family conclusion but cannot linearly multiply that family's influence.

## Consensus outputs

The Consensus Engine exposes:
- Direction Score: -100 bearish to +100 bullish.
- Confidence: 0–100 evidence quality/coverage/agreement score.
- Bullish Support.
- Bearish Support.
- Agreement.
- Conflict.
- Provider Coverage.
- Family Coverage.
- Independent Family Count.
- Per-family direction, strength, reliability and evidence count.


## Presentation rule: simple first, technical on demand

The Consensus Engine may calculate detailed internal metrics, but the default investor-facing surface must remain understandable. The primary Recommendation Insight presents only:
- Signal Strength — how strongly the combined evidence leans bullish or bearish.
- Confidence — how much trust the engine places in the conclusion after coverage, alignment and reliability adjustments.
- Signal Alignment — whether independent evidence groups agree.

Agreement, conflict, family coverage, provider coverage, reliability and per-family internals are preserved behind `How was this calculated?` and info controls. Confidence must be described as model confidence, not a guaranteed probability of profit.

## Direction is not confidence

Examples:

BUY
- Direction: +58 bullish
- Confidence: 61%

This means bullish evidence leads, but the evidence quality, breadth or agreement is only moderate.

HOLD
- Direction: +2 neutral
- Confidence: 78%
- Conflict: high

This can be valid when strong independent bullish and bearish families cancel each other. The engine may be highly confident that there is no clear directional edge.

## Stock-normalized analysis

TradePilot AI should prefer comparisons against a stock's own normal behavior over universal thresholds whenever possible.

Examples:
- Current volume vs recent average volume.
- Intraday volume vs the same time-of-day across previous sessions.
- ATR% vs the stock's historical ATR%.
- Current volatility vs its historical volatility regime.
- Momentum and trend persistence vs the stock's own history.

## Historical Stock DNA and current regime

v0.6 separates two concepts that must not be confused:

**Stock Type** is structural behavior learned from one-year daily history:
- Steady
- Balanced
- Volatile

**Volatility Regime** is the current 20-session realized-volatility state compared with that same stock's own historical distribution:
- Calm: <= 25th percentile
- Normal: 25th–75th percentile
- Elevated: >= 75th percentile

Long-term inputs currently include rolling normalized ATR%, rolling annualized realized volatility, 20D/60D daily-volume baselines, volume variability and 20D/60D trend efficiency. At least 60 valid daily sessions are required for historical Stock DNA.

If historical data is unavailable, the recommendation engine falls back to the short active-analysis snapshot.

## Current context-aware weighting

Implemented through v0.6:
- RSI is discounted when a stock is historically volatile or when the current move is strongly directional.
- RSI can receive slightly more trust in historically steady stocks.
- RSI is further discounted when current volatility is elevated versus the stock's own history.
- Candle Trend is boosted when an inherently volatile stock moves with high directional efficiency.
- Candle Trend is discounted when volatile movement is noisy.
- Elevated historical volatility requires cleaner directional/participation confirmation before Trend receives extra conviction.
- Relative Volume receives more weight when current analysis-window volume is materially abnormal.
- A moderate volume spike carries more weight when the stock's historical daily volume is normally stable, and less weight when daily volume is naturally erratic.

Stock DNA never emits Buy/Sell by itself. It only changes the interpretation and weight of evidence.

## Brain roadmap

### v0.6 — Historical Context / Stock DNA foundation
Implemented:
- Separate current regime from long-term stock personality.
- One-year daily history as the preferred baseline.
- Rolling normalized ATR% and realized-volatility baselines.
- Current volatility percentile against the stock's own history.
- 20D/60D daily volume and volume variability.
- 20D/60D trend efficiency.
- Historical context integrated into evidence weighting.

Deferred intentionally:
- Same-time-of-day RVOL until true matching intraday history is available.
- Gap/earnings-gap behavior until event-aware data is available.

### v0.7 — Multi-Timeframe + Market Context Intelligence
- Strategy-role hierarchy with a selectable Trader primary interval and automatically selected confirmation/backdrop intervals.
- Higher-timeframe trend stays inside the Trend family.
- Relative strength vs broad market and sector.
- Market Context as an independent evidence family.

### v0.8 — Advanced Trader evidence
Implemented:
- EMA Structure inside Trend.
- MACD Momentum inside Momentum, with histogram strength normalized by price.
- Volume Confirmation inside Participation.
- Analysis-window VWAP Position inside Price Structure.
- ATR-normalized local Support & Resistance inside Price Structure.
- ATR-normalized Price Extension inside Volatility.
- Evidence UI grouping by evidence family.

Deferred intentionally:
- ADX until historical validation shows it adds information beyond trend efficiency + EMA/Candle/Multi-Timeframe structure.
- Bollinger Bands until evidence shows incremental value beyond Stock DNA, ATR and Price Extension.
- True session VWAP until the live provider exposes reliable session boundaries.

### v0.9 — Historical Setup Validation
- Setup fingerprint from de-duplicated family state + Stock DNA + market context.
- Similar historical case matching.
- Follow-through vs a context-matched same-stock baseline that shares strategy, interval, Stock Profile, volatility regime and Market Environment but does not require today's specific evidence setup.
- Effective sample size, similarity quality, median forward move and excursion analysis.
- Bounded confidence-only adjustment; direction remains deterministic from current evidence.
- Synthetic development provider behind a replaceable historical-data interface.

### v0.10 — Event / broader-environment context
- Earnings calendar/risk.
- News and sentiment.
- Market breadth/regime.
- Volatility/risk regime.

### v1.0 — Swing and Investor brains
- Swing-specific daily/weekly evidence.
- Investor fundamentals, valuation, growth, quality and revisions.

### v1.x — Historical calibration + AI Analyst
- Replace development analogs with real historical setup/outcome storage.
- Walk-forward / out-of-sample calibration.
- Evidence effectiveness by stock and regime.
- No live weight optimization from in-sample performance alone.
- AI explanations grounded in deterministic current evidence + validated history.

## Explainability rule

AI explains deterministic facts; AI does not invent the recommendation.

Every recommendation should eventually answer:
- What supports it?
- What opposes it?
- Which evidence families are independent?
- What evidence is redundant?
- How reliable is each input?
- How did stock context change its weight?
- What would change the recommendation?
- How did similar historical conditions perform out of sample?


## v0.7 environment/context layer

The brain now adds two context paths before consensus:

```text
User-selected Trader primary snapshot
      +
automatic confirmation + broader backdrop
      -> Multi-Timeframe Trend -> Trend family

Stock confirmation/backdrop
+ broad-market confirmation/backdrop
+ sector confirmation/backdrop
      -> Market Context -> Market Context family
```

The first path is deliberately kept in the Trend family so higher-timeframe observations improve trend interpretation without becoming false independent votes. The second path is independent environmental evidence because relative stock/sector/market behavior measures a different question from the stock's own momentum or trend.

Trader primary choices are 1m, 5m, 15m, 30m and 1h. The default remains 5m. Supporting intervals are not independently user-selected because TradePilot must preserve a coherent hierarchy:
- 1m -> 5m confirmation -> 1h backdrop
- 5m -> 1h confirmation -> 1d backdrop
- 15m -> 1h confirmation -> 1d backdrop
- 30m / 1h -> 4h confirmation -> 1d backdrop

Future Swing and Investor strategies use different policies rather than inheriting Trader settings. Swing defaults to 1d primary with 1w confirmation and 1mo regime. Investor defaults to 1w technical context with 1mo confirmation and 3mo regime, but long-term fundamentals/valuation remain more important than technical interval selection.

The Price History selector remains presentation-only and is independent from these analysis intervals.


## v0.8 direction-versus-entry-quality rule

Technical direction and entry quality are not the same question. A stock may have bullish Trend, Momentum and Market Context while Price Extension is bearish because the move is already stretched. The Volatility family is allowed to reduce confidence or oppose a fresh entry without rewriting the underlying trend as bearish. This is a permanent brain rule.


## Explainable attribution layer

The Consensus Engine emits exact post-de-duplication attribution alongside its direction/confidence outputs. Each evidence family receives a signed direction-impact value and a confidence-contribution value. Provider-level values reconcile to the family total while preserving the family cap. Family direction impacts reconcile to the final -100..+100 direction score; family confidence points reconcile to final confidence. The UI may convert these exact values into percentage shares, but it must retain the signed point values for technical drill-down.

Confidence attribution is not treated as a probability model. The engine first builds an evidence-strength baseline, then applies provider coverage, evidence-group coverage, signal alignment and reliability factors. These adjustments are emitted as explicit confidence-modifier impacts so the user can see what reduced confidence.


## v0.9 historical-validation overlay

Historical setup validation runs **after** the Consensus Engine. It receives the current Recommendation, Stock DNA and Analysis Context, builds a setup-time fingerprint, finds similar historical cases, evaluates their later outcomes, and returns a bounded confidence modifier.

```text
Current evidence -> Consensus Engine -> direction + evidence confidence
                                      |
                                      v
                              Setup fingerprint
                                      |
                                      v
                           Historical analog match
                                      |
                         outcomes vs context-matched stock baseline
                                      |
                                      v
                       bounded confidence modifier
                                      |
                                      v
                              final confidence
```

Permanent constraints:
- Historical validation is not an evidence family.
- It cannot change direction in v0.9.
- Maximum confidence impact is ±8 points.
- Positive impact requires matched same-direction follow-through above 50% and above the context-matched same-stock baseline.
- Similarity uses family-level state, not duplicated provider votes.
- Kish effective sample size is reported because similarity-weighted observations do not have the same information content as an equal-weight raw count.
- Historical features use setup-time information only; forward returns/excursions are evaluation-only.
- Development synthetic data is always labeled and cannot be presented as historical performance.

## v0.9 Historical Validation Weighting Rule

Historical validation uses unequal outcome weights and a separate reliability gate:

- Historical Difference vs context-matched stock baseline: 40%
- Directional follow-through: 20%
- Volatility/behavior-normalized outcome magnitude: 20%
- Favorable vs adverse excursion quality: 20%

Effective sample depth and match quality do not receive outcome weights. They are reliability gates applied after the weighted historical quality score; the weaker reliability dimension limits the historical confidence impact. Historical validation remains bounded to ±8 confidence points and cannot directly alter recommendation direction.


## v0.10 external-context architecture

`RecommendationContextService` now loads a replaceable `ExternalContextProvider` alongside multi-timeframe stock/benchmark data. The current mock provider returns Market Breadth, Event Risk and News Sentiment profiles.

- Market Breadth -> `MarketBreadthEvidenceProvider` -> `EvidenceFamily.marketContext`.
- News Sentiment -> `NewsSentimentEvidenceProvider` -> `EvidenceFamily.sentiment`.
- Event Risk -> `EventRiskConfidenceAdjuster` -> confidence modifier only, capped at 12 points.

This role separation is intentional: breadth is related to existing market context, news can carry independent direction when data quality is sufficient, and scheduled-event proximity represents uncertainty/risk rather than direction.
