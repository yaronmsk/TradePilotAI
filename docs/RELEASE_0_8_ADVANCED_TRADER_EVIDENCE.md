# TradePilot AI v0.8.0 — Advanced Trader Evidence

Status: Development / validation
Date: 2026-08-18

## Goal

Improve the Trader brain with richer technical evidence without turning the recommendation into a simple indicator count.

The release adds six signals, but only two new independent evidence groups. Related indicators remain grouped so adding more technical tools improves interpretation rather than inflating confidence.

## Competitor research translated into requirements

### TradingView

TradingView Technical Ratings combine 26 constituent indicators, including multiple moving averages and oscillators, into compact Buy/Sell-style ratings. TradingView also documents VWAP as an intraday volume-weighted price reference and MACD as a momentum/trend tool.

Useful patterns:
- Compact summaries are easier to consume than dozens of raw indicators.
- Moving averages, oscillators, VWAP and MACD all provide useful but overlapping technical views.

TradePilot enhancement:
- Signals are not averaged as equal independent votes.
- EMA and Candle Trend remain inside Trend.
- RSI and MACD remain inside Momentum.
- Relative Volume and Volume Confirmation remain inside Volume Activity.
- VWAP and Support/Resistance share Price Structure.
- Price Extension gets a separate Volatility/Risk role.
- Direction and confidence remain separate.

Sources:
- https://www.tradingview.com/support/solutions/43000614331-technical-ratings/
- https://www.tradingview.com/support/solutions/43000502018-volume-weighted-average-price-vwap/
- https://www.tradingview.com/support/solutions/43000502344-moving-average-convergence-divergence-macd-indicator/
- https://www.tradingview.com/support/solutions/43000502589-moving-averages/

### TrendSpider

TrendSpider provides VWAP/Anchored VWAP and automated support/resistance heatmaps. Its support/resistance tooling explicitly focuses on identifying repeated price areas rather than treating every line as a directional prediction.

Useful patterns:
- Automated structure detection can remove manual chart drawing.
- VWAP is particularly relevant to active intraday trading.
- Support/resistance is better represented as an area/context signal than a guaranteed barrier.

TradePilot enhancement:
- Price structure becomes deterministic recommendation evidence.
- VWAP and support/resistance are grouped together so they cannot double-count the same structure story.
- Support/resistance distances are normalized with ATR rather than one fixed percentage threshold.
- The current implementation labels these as local analysis-window levels and never claims certainty.

Sources:
- https://help.trendspider.com/kb/indicators/volume-weighted-average-price
- https://help.trendspider.com/kb/automated-technical-analysis/horizontal-support-and-resistance-heatmaps
- https://help.trendspider.com/kb/indicators/volume-lower

### StockCharts

StockCharts describes MACD as a momentum oscillator derived from moving averages and repeatedly emphasizes volume confirmation around breakouts and support/resistance.

Useful patterns:
- A breakout with stronger volume deserves more trust than one with weak participation.
- MACD adds momentum-transition information but is still derived from moving averages.

TradePilot enhancement:
- MACD strength is normalized by stock price before scoring, reducing raw-price-scale distortion.
- Volume Confirmation compares recent average activity with the preceding window and checks whether participation confirms or diverges from price direction.
- Relative Volume and Volume Confirmation remain one independent Participation group.

Sources:
- https://chartschool.stockcharts.com/table-of-contents/technical-indicators-and-overlays/technical-indicators/macd-moving-average-convergence-divergence-oscillator
- https://chartschool.stockcharts.com/table-of-contents/overview/john-murphys-charting-made-easy-ebook

## New evidence providers

### EMA Structure
Family: Trend

Checks:
- price vs EMA 9,
- EMA 9 vs EMA 21,
- normalized spread between the two averages.

Purpose:
Confirm whether the active short-term move has clean trend structure.

De-duplication:
Candle Trend, EMA Structure and Multi-Timeframe Trend all remain one Trend group.

### MACD Momentum
Family: Momentum

Checks:
- MACD vs signal line,
- histogram sign,
- histogram strength normalized by current stock price.

Purpose:
Measure acceleration/deceleration without treating raw MACD magnitude equally across differently priced securities.

De-duplication:
RSI and MACD are both Momentum signals and therefore cannot create two independent momentum votes.

### Volume Confirmation
Family: Participation

Checks:
- recent average volume vs preceding average volume,
- price direction across the same window,
- confirmation versus divergence.

Purpose:
Distinguish a directional move with expanding participation from a move occurring on fading activity.

De-duplication:
Relative Volume and Volume Confirmation remain one Participation group.

### VWAP Position
Family: Price Structure

Checks:
- latest price vs volume-weighted average price across the active analysis window.

Important limitation:
The current mock/provider layer does not expose authoritative market-session boundaries. Therefore v0.8 calls this an **analysis-window VWAP**, not a guaranteed full-session VWAP. Real session VWAP will replace it when the live provider supplies proper intraday session data.

### Support & Resistance
Family: Price Structure

Checks:
- recent prior-candle high/low structure,
- distance to local support/resistance,
- breakout/breakdown buffer normalized by ATR.

Purpose:
Detect whether price is between levels, testing a level, or moving beyond one.

Important limitation:
These are deterministic local levels from the active analysis window, not probabilistic guarantees that price will hold or reverse.

### Price Extension
Family: Volatility

Checks:
- distance from EMA 21,
- normalized by ATR.

Purpose:
Separate trend direction from entry quality. A stock can remain strongly bullish while being too extended to justify chasing a fresh long entry.

This is intentionally lower-weight risk/opposition evidence rather than another trend vote.

## Evidence-family map after v0.8

Trend:
- Candle Trend
- EMA Structure
- Multi-Timeframe Trend

Momentum:
- RSI
- MACD Momentum

Volume Activity:
- Relative Volume
- Volume Confirmation

Price Structure:
- VWAP Position
- Support & Resistance

Volatility:
- Price Extension

Market Context:
- Market & Sector Context

The active Trader brain can therefore evaluate eleven provider-level signals while exposing at most six independent technical/context groups.

## Context-aware weighting

Stock DNA continues to change interpretation:
- EMA trend evidence follows the same noisy-vs-directional rules as Candle Trend.
- MACD is discounted in noisy volatile movement and modestly boosted in clean trends.
- Volume Confirmation inherits stock-specific volume abnormality/variability weighting.
- VWAP is slightly discounted for inherently volatile stocks and can gain weight when participation is elevated.
- Support/resistance is discounted in elevated, noisy volatility.
- Price Extension receives slightly more weight for steady stocks and slightly less weight in exceptionally clean trends that can remain stretched.

## Evidence UI

v0.8 also changes the Evidence section from one long list of individual cards into expandable evidence-group sections.

Default view:
- Trend Evidence
- Momentum Evidence
- Volume Activity Evidence
- Price Structure Evidence
- Volatility Evidence
- Market Context Evidence

Each group shows its signal count and family direction. The user can expand a group to inspect every provider, calculation, reliability and context-adjusted weight.

This keeps the default experience understandable while preserving full explainability.

## Explicitly not added

ADX is intentionally deferred. The brain already measures trend efficiency, ATR-normalized volatility, Candle Trend, EMA Structure and multi-timeframe trend. ADX would currently add significant overlap before we have historical evidence that it improves the family conclusion.

Traditional Bollinger Bands are also deferred because Stock DNA + ATR + Price Extension already cover much of the volatility/extension question. They can be reconsidered if backtesting proves they add independent value.

## Validation focus

v0.8 tests must prove:
- each provider classifies clean bullish/bearish/neutral scenarios correctly,
- provider data requirements fail gracefully,
- new signals remain mapped to the intended evidence families,
- duplicate signals inside a family do not increase independent-family count,
- Stock DNA still changes dynamic weights,
- evidence UI groups large numbers of signals instead of exposing eleven full cards by default.


## Recommendation attribution refinement

v0.8 also makes the recommendation mathematically attributable. Recommendation Insight shows each independent evidence group's share of directional influence and share of final confidence. Expanding a group shows the exact provider-level direction and confidence points. The calculation is performed after evidence-family de-duplication, so correlated providers do not receive independent full votes. Confidence calculation also exposes the evidence-strength baseline and the exact coverage, alignment and reliability adjustments that produce final confidence. See `RELEASE_0_8_ATTRIBUTION_REFINEMENT.md`.
