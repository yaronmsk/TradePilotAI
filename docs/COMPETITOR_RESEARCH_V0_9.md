# TradePilot AI v0.9 — Competitor Research: Historical Setup Validation

Research checkpoint: 2026-08-20

## Research question

How do established trading platforms and newer historical-analog products validate a current setup against history, and how can TradePilot AI make that capability more statistically honest, strategy-aware, and explainable?

## TrendSpider

TrendSpider's Strategy Tester backtests rule-based strategies and its Price Behavior Explorer reports mean/median change, position count, percentiles and a random-control comparison. Its documentation explicitly explains that the random control helps distinguish a strategy effect from a generally rising market.

Useful patterns:
- Do not report only win rate.
- Show the number of observations and outcome distribution.
- Compare matched/strategy behavior with a background control.
- Treat backtesting as evidence, not proof of future performance.

TradePilot enhancement:
- Historical validation is attached to the *current deterministic recommendation* rather than being a separate strategy screen.
- Similarity is computed from the same de-duplicated evidence families, Stock DNA and market context that created the live recommendation.
- Control outcomes are part of the confidence calculation, not merely a chart overlay.

Sources:
- https://help.trendspider.com/articles/what-is-the-strategy-tester
- https://help.trendspider.com/kb/strategy-tester/read-and-analyzing-test-results
- https://help.trendspider.com/kb/strategy-tester/understanding-strategy-tester-from-trendspider

## TradingView

TradingView supports strategy backtesting, forward testing and Deep Backtesting across a much larger historical dataset. Its Strategy Report separates historical simulation metrics from the live chart and emphasizes that strategy settings and available history affect results.

Useful patterns:
- Historical evaluation needs a defined strategy and a defined data window.
- Forward/out-of-sample behavior matters separately from in-sample backtesting.
- A large historical sample is useful, but data depth differs by timeframe.

TradePilot enhancement:
- v0.9 is not a generic backtest of arbitrary user rules. It asks a narrower question: "when the deterministic TradePilot setup looked similar, what happened next?"
- Outcome windows are strategy/timeframe-specific so a 1-minute Trader setup is not judged on the same horizon as a 1-hour or future Swing setup.

Sources:
- https://www.tradingview.com/support/solutions/43000562362-what-are-strategies-backtesting-and-forward-testing/
- https://www.tradingview.com/support/solutions/43000666265-how-deep-backtesting-works/

## Trade Ideas OddsMaker

Trade Ideas OddsMaker reports metrics such as profit factor, win rate, average winner/loser, equity curve and drawdown over historical strategy occurrences.

Useful pattern:
- Historical results should expose more than one headline probability.

TradePilot enhancement:
- The historical layer reports follow-through rate, control rate, match quality, effective sample size, median directional move and favorable/adverse excursion.
- It is an explainability/validation layer rather than an autonomous recommendation source.

Source:
- https://forums.trade-ideas.com/guide/chapter/22/22Backtesting_Oddsmaker.html

## Konseki / historical analog products

Konseki directly searches historical market data for structurally similar stock setups and reports match quality, number of historical matches, positive-outcome rate, median move and adverse/favorable path behavior.

Useful patterns:
- Similarity quality should be visible.
- Cross-symbol matches can increase sample breadth.
- Median outcome and adverse excursion are often more useful than a single average.

TradePilot enhancement:
- The current setup fingerprint is not only chart shape. It is built from independent evidence-family states, stock structural behavior, volatility regime, market environment, relative strength and strategy interval.
- Same-symbol matches receive a modest statistical-weight preference without receiving an artificial similarity bonus.
- Historical analogs cannot become another independent evidence family and cannot double-count the indicators that generated them.

Source:
- https://konseki.io/

## Statistical caution: backtest overfitting

Bailey, Borwein, López de Prado and Zhu show that repeated selection/optimization over historical backtests can produce overfit strategies with poor out-of-sample behavior.

Permanent TradePilot implications:
- Historical validation is bounded and cannot rewrite recommendation direction in v0.9.
- Positive historical credit requires matched outcomes to beat both a 50/50 directional baseline and a control sample.
- Small/effectively concentrated samples receive lower reliability.
- Future self-learning must use walk-forward/out-of-sample validation before changing live weights.

Source:
- https://papers.ssrn.com/sol3/Papers.cfm?abstract_id=2326253

## v0.9 product decision

TradePilot AI will implement **Historical Setup Validation**, not a generic backtester and not a predictive analog engine.

The historical layer answers:
1. How many sufficiently similar historical cases exist?
2. How similar are they to the current setup?
3. How often did they follow through in the current signal direction?
4. Did they do better than an unconditional/control sample?
5. What was the median forward move?
6. How far did outcomes typically move for and against the signal?
7. How reliable is the sample after similarity weighting?
8. Should this history adjust confidence, and by how much?

It does **not** independently choose Buy/Sell direction.
