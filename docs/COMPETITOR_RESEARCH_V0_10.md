# TradePilot AI v0.10 Competitor Research

Research checkpoint: August 2026

## Scope

v0.10 expands the Trader brain beyond stock-local technical evidence into three external context layers:

- Market breadth / participation.
- Scheduled event risk.
- Recent company-news sentiment.

## Comparable product patterns

### TradingView

TradingView exposes market breadth indicators such as Advance/Decline, and separate calendars for earnings and economic events. Its News Flow provides filtered, multi-provider company and market news.

Useful pattern: make breadth, events and news visible and easy to inspect.

TradePilot enhancement: these inputs become deterministic recommendation context with explicit roles instead of remaining separate research screens.

### TrendSpider

TrendSpider emphasizes multi-factor strategy testing and contextual analysis. Its product philosophy reinforces that technical conditions should be assessed in a broader market/strategy context rather than as isolated indicators.

Useful pattern: combine multiple conditions while retaining inspectability.

TradePilot enhancement: related context remains family-capped, and scheduled event risk is treated as a confidence/risk overlay rather than a directional vote.

### Seeking Alpha

Seeking Alpha's Quant system compares many metrics within factor groups and states that the final rating is not a simple average; some factors carry more weight and poor values can cap the result.

Useful pattern: not every metric should have equal influence.

TradePilot enhancement: news sentiment is reliability-weighted by source diversity, freshness and materiality, while event risk can only reduce confidence and cannot create Buy/Sell direction by itself.

## v0.10 design rules

1. **Market Breadth is not a new independent market vote.** It belongs to the existing Market Context evidence family alongside Market & Sector Context.
2. **Event Risk is not directional evidence.** Earnings/macro proximity can reduce confidence because of gap/volatility uncertainty, but cannot turn bullish evidence bearish by itself.
3. **News Sentiment is directional evidence, but reliability-gated.** Article count alone is insufficient. Source diversity, freshness and materiality affect reliability/weight.
4. **Synthetic data is explicitly labeled.** The v0.10 mock provider demonstrates architecture only and must never be presented as real current market/news/event data.
5. **All effects remain auditable.** Market breadth appears in Evidence Contribution; event risk appears as its own confidence modifier; news sentiment appears as a Sentiment evidence family.

## Production-data requirements

Before live use:

- Breadth provider with licensed constituent/advance-decline data.
- Corporate calendar provider with reliable earnings timestamps and update metadata.
- Economic-calendar provider with event importance and timing.
- News provider with article identity, timestamp, source, entity relevance and licensing rights.
- Deduplication of syndicated/reposted headlines.
- Source-quality and freshness calibration against real historical outcomes.
