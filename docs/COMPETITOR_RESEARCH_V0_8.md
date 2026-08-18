# v0.8 Competitor Research — Advanced Trader Evidence

Date: 2026-08-18

## Research question

How do leading technical-analysis platforms present moving averages, momentum, VWAP, support/resistance and volume confirmation, and what should TradePilot AI do differently?

## Findings

### TradingView

Technical Ratings compactly aggregate 26 indicator conditions across moving averages and oscillators. This is convenient, but its documented calculation primarily averages constituent ratings.

TradePilot takeaway:
- Keep the compact user-facing summary.
- Do not assume 26 signals equal 26 independent pieces of evidence.
- Group correlated signals before confidence is calculated.

TradingView also describes moving averages as lagging/reactive tools used for confirmation rather than prediction, and VWAP as primarily an intraday price/volume reference.

Sources:
- https://www.tradingview.com/support/solutions/43000614331-technical-ratings/
- https://www.tradingview.com/support/solutions/43000502589-moving-averages/
- https://www.tradingview.com/support/solutions/43000502018-volume-weighted-average-price-vwap/
- https://www.tradingview.com/support/solutions/43000502344-moving-average-convergence-divergence-macd-indicator/

### TrendSpider

TrendSpider exposes VWAP/Anchored VWAP, automated support/resistance heatmaps and volume tools that help evaluate whether a level may hold or break.

TradePilot takeaway:
- Automate structure interpretation instead of making the user draw every level.
- Treat support/resistance as contextual evidence, not certainty.
- Couple price structure with participation when judging breakouts.

Sources:
- https://help.trendspider.com/kb/indicators/volume-weighted-average-price
- https://help.trendspider.com/kb/automated-technical-analysis/horizontal-support-and-resistance-heatmaps
- https://help.trendspider.com/kb/indicators/volume-lower

### StockCharts

StockCharts describes MACD as a momentum oscillator derived from moving averages and emphasizes that heavier volume around breaks of trendlines/support/resistance lends greater weight to the move.

TradePilot takeaway:
- MACD belongs in Momentum, not as a fully independent trend vote.
- Volume confirmation should explicitly test whether participation is expanding with price direction.

Sources:
- https://chartschool.stockcharts.com/table-of-contents/technical-indicators-and-overlays/technical-indicators/macd-moving-average-convergence-divergence-oscillator
- https://chartschool.stockcharts.com/table-of-contents/overview/john-murphys-charting-made-easy-ebook

## TradePilot differentiation

TradePilot AI v0.8 focuses on **evidence architecture**, not indicator quantity:

1. Correlated indicators share a family.
2. Family influence is capped before consensus.
3. Stock DNA changes provider weights.
4. ATR/price normalization replaces fixed raw-value thresholds when appropriate.
5. Direction and entry quality can disagree.
6. The default UI groups evidence by meaning and keeps detailed provider cards behind expansion.
7. Limitations such as analysis-window VWAP and local support/resistance are stated explicitly instead of being presented as production-grade market-session calculations.
