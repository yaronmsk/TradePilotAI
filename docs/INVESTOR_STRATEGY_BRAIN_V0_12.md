# TradePilot AI — v0.12.0 Investor Strategy Brain

Status: Architecture / research scope opened
Release: v0.12.0
Baseline: v0.11.0 — Swing Strategy Brain
Baseline commit: 665fd8f0be86c8ce62cb2d37e1d2acbda910bd69
Baseline tag: v0.11.0
Scope opened: 2026-09-01

## Purpose

Investor is TradePilot AI's months-to-years strategy.

Investor is not Swing running on weekly/monthly candles. The company/business thesis must dominate, while market, macro, positioning and long-term technical context refine timing, confidence and risk.

The Investor brain must answer two different questions:

1. How strong, healthy, durable and attractively valued is the business?
2. What are observable markets, macro conditions and investor positioning currently implying about that business and its future expectations?

## Research basis

Batch 0 reviewed current public methodologies and data sources:

- Seeking Alpha separates Value, Growth, Profitability, Momentum and EPS Revisions and uses sector-relative comparison.
- Morningstar separates fair value, uncertainty and durable competitive advantage/economic moat.
- TipRanks separately exposes analyst, hedge-fund/institutional, insider, news, technical and fundamental factors.
- Fama/French research separates market, value, profitability and investment effects across regions.
- SEC EDGAR exposes structured XBRL company facts.
- SEC Form 13F exposes institutional holdings, but the data is quarterly and filings may lag quarter end by up to 45 days.
- Federal Reserve/FRED data can support rates and financial-conditions regimes.
- Cboe VIX measures expected market volatility and is explicitly non-directional.

TradePilot AI will not copy proprietary formulas. These sources only inform architecture and measurable input categories.

## Permanent Investor rules

### Fundamentals must dominate

An actionable Investor BUY/SELL requires sufficient independent core-fundamental coverage.

Technical, macro, sentiment or positioning evidence cannot satisfy the action-breadth gate by themselves.

If core fundamentals are missing, return a typed non-action state.

### Do not use one giant Fundamentals family

The current `EvidenceFamily.fundamentals` placeholder is too coarse.

Investor requires independent families because Growth, Profitability, Financial Strength, Valuation and Revisions answer economically different questions. Collapsing them into one family would incorrectly de-duplicate them under the existing family cap.

### Proposed core families

1. **Growth**
   - revenue growth
   - EPS growth where meaningful
   - free-cash-flow/per-share growth
   - 3Y/5Y CAGR
   - acceleration/deceleration

2. **Profitability & Quality**
   - gross/operating/FCF margins
   - ROIC/capital efficiency
   - margin stability
   - cash conversion / earnings quality

3. **Financial Strength**
   - leverage
   - net debt
   - interest coverage
   - liquidity
   - debt trend/refinancing risk
   - business-model-specific rules for banks, insurers, REITs, etc.

4. **Valuation**
   - P/E where meaningful
   - EV/EBITDA / EV/EBIT
   - price/free cash flow / FCF yield
   - valuation versus own history
   - valuation versus relevant peers
   - no falsely precise single DCF point in initial v0.12

5. **Revisions**
   - EPS/revenue revision breadth
   - magnitude and direction
   - 30D/90D changes
   - estimate dispersion
   - requires authoritative point-in-time estimate data

6. **Competitive Durability**
   - ROIC persistence
   - margin persistence
   - market-share/pricing-power proxies only when reliable
   - no invented opaque moat score

7. **Capital Allocation & Dilution**
   - share-count change
   - SBC burden
   - buybacks net of issuance
   - dividend sustainability
   - debt-funded distributions
   - reinvestment efficiency

### Context / timing layers

**Long-Term Market Context**
- global/regional market regime
- sector/industry regime
- stock relative strength versus market/sector
- long-horizon breadth where reliable

**Long-Term Technical Context**
- weekly/monthly structural trend
- secondary timing role
- cannot replace the business thesis

**Ownership & Positioning**
- institutional ownership trend
- institutional-holder breadth/concentration
- insider activity where authoritative
- short interest where authoritative and horizon-compatible
- 13F latency must be visible in reliability/explainability

**Persistent Information / Sentiment**
- only material, durable thesis changes
- low/capped Investor influence
- short-lived headline tone must not drive long-term recommendations

## Global Market & Macro Context

This is a first-class Investor context layer, but it is not a single "global sentiment" score.

Candidate measurable inputs:

- policy-rate regime
- long-term yields
- yield-curve shape
- real-rate regime where available
- financial-conditions indices
- credit/risk conditions where reliable
- inflation trend
- broad/regional equity regime
- market-implied volatility, explicitly non-directional
- currency regime
- commodity regime when the company has measurable exposure

### Stock Sensitivity Profile

Prefer stock-specific exposure over universal macro assumptions.

Candidate methodology:
- weekly observations
- multi-year rolling history
- minimum sample gate
- market + sector sensitivity first
- macro/factor exposure only when statistically stable
- reliability penalty for unstable coefficients, low explanatory power or collinearity
- unavailable is better than false precision

Potential exposed sensitivities:
- market
- sector
- rates
- currency
- commodity
- regional
- factor/style where useful

Global Macro Context may adjust:
- confidence
- valuation interpretation
- risk/timing
- capped direction only when stock-specific exposure is demonstrably measured

It cannot create Investor BUY/SELL by itself.

## Market Expectations & Positioning

The UI should help answer:

> Is the current market price/positioning demanding unusually strong execution, roughly matching current fundamentals, or pricing relatively conservative expectations?

Possible conclusions:
- Expectations look conservative
- Expectations look balanced
- Expectations look demanding
- Expectations look very demanding
- Not enough data

This is a **zero-vote presentation helper**.

It may summarize already-counted:
- Growth
- Quality
- Valuation
- Revisions
- Ownership/Positioning

It adds zero evidence votes, zero direction points and zero confidence points.

This prevents double counting.

## Direction / confidence / breadth

All v0.11 invariants remain:

- direction attribution uses actual effective post-family-cap influence
- active directional basis reconciles to 100%
- provider influence reconciles to family influence
- supportive/opposing influence remains visible
- confidence attribution remains separate
- confidence-only modifiers remain explicit point adjustments

Before production Investor scoring, freeze:
- core-fundamental family list
- minimum core-family breadth
- provider coverage requirement
- action direction threshold
- action confidence threshold
- conflict behavior
- maximum context/timing influence

## Sector and business-model normalization

Do not apply one universal ratio model to every company.

Examples:
- banks/insurers need financial-sector balance-sheet rules
- REITs need FFO/AFFO-style economics
- unprofitable growth companies need different valuation interpretation
- cyclicals need cycle-aware normalization
- capital-intensive firms require different reinvestment/cash-flow interpretation

Unsupported categories should be unavailable rather than misleading.

## Data-provider boundaries

Proposed replaceable interfaces:

- `FundamentalDataProvider`
- `AnalystEstimateProvider`
- `PeerClassificationProvider`
- `MacroContextProvider`
- `OwnershipPositioningProvider`
- `InvestorHistoricalDataProvider`

Initial U.S. authoritative candidate for reported fundamentals: SEC EDGAR XBRL/companyfacts.

Analyst revisions and many peer/positioning datasets may require licensed providers. Until selected, development data must remain clearly synthetic.

## Point-in-time historical discipline

Investor history must use information actually available on the historical setup date.

- SEC facts become usable at filing/publication time, not fiscal-period end.
- 13F holdings become usable at filing/publication time, not quarter end.
- analyst revisions require point-in-time historical estimate data.
- restatements must not silently create historical look-ahead.

Candidate Investor forward validation windows:
- 6 months
- 12 months
- 24 months

Historical Setup Validation remains confidence-only unless a future release explicitly proves and approves another role.

## Proposed UI order

1. Strategy Summary
2. Investor Analysis Context
3. Investor Recommendation
4. Investor Recommendation Insight
5. Business Strength
6. Valuation & Expectations
7. Global Market Context
8. Ownership & Positioning
9. Investor Evidence
10. Investor Risk
11. Historical Setup Validation

Every visible analytical value requires its own info/explainability path.

## Proposed implementation sequence

- **Batch 0** — research, scope, evidence audit
- **Batch 1** — Investor domain/family/provider-contract foundation
- **Batch 2** — Growth + Profitability/Quality
- **Batch 3** — Financial Strength + Capital Allocation
- **Batch 4** — Valuation
- **Batch 5** — Revisions + Competitive Durability
- **Batch 6** — Global Market & Macro Context + Stock Sensitivity Profile
- **Batch 7** — Ownership/Positioning + zero-vote Market Expectations helper
- **Batch 8** — Investor recommendation policy + attribution
- **Batch 9** — Investor Historical Setup Validation
- **Batch 10** — Investor UI activation
- **Batch 11** — v0.12.0 release acceptance

## Acceptance criteria

v0.12.0 is not complete until:

- Investor is a genuine months-to-years strategy.
- Independent fundamental families replace the single generic Fundamentals concept.
- actionable Investor recommendations require core-fundamental breadth.
- Global Market/Macro Context uses observable data plus stock-specific sensitivity rather than vague opinion.
- Market Expectations is transparent and zero-vote.
- positioning data exposes latency and limitations.
- sector/business-model normalization prevents invalid universal ratios.
- point-in-time rules prevent historical look-ahead leakage.
- BUY/SELL parity is tested for every directional family.
- direction and confidence attribution remain mathematically separate.
- every visible Investor metric/value has its own explainability path.
- Trader and Swing remain regression-protected.
- mock/synthetic Investor data is always labeled.

## Initial non-goals

- opaque 0–100 Investor score
- AI-generated moat score without grounded deterministic inputs
- social-media sentiment as a core Investor family
- intraday order flow
- session VWAP
- short-horizon options positioning as a core Investor input
- falsely precise single DCF value
- live claims from mock data
- self-learning/reweighting before point-in-time out-of-sample validation

## Research sources

- Seeking Alpha Quant Ratings:
  https://help.seekingalpha.com/premium/what-are-quant-ratings-and-how-do-i-use-them
- Morningstar stock ratings:
  https://www.morningstar.com/help-center/stocks/morningstar-ratings-for-stocks
- TipRanks Smart Score:
  https://www.tipranks.com/news/labs/get-a-full-stock-analysis-with-tipranks-smart-score
- SEC EDGAR APIs:
  https://www.sec.gov/search-filings/edgar-application-programming-interfaces
- SEC Form 13F datasets:
  https://www.sec.gov/data-research/sec-markets-data/form-13f-data-sets
- SEC Form 13F FAQ:
  https://www.sec.gov/rules-regulations/staff-guidance/division-investment-management-frequently-asked-questions/frequently-asked-questions-about-form-13f
- Kenneth French developed-market five-factor description:
  https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/Data_Library/f-f_5developed.html
- Chicago Fed ANFCI via FRED:
  https://fred.stlouisfed.org/series/ANFCI
- Cboe VIX explanation:
  https://www.cboe.com/insights/posts/what-the-vix-and-vix-1-d-indices-attempt-to-measure-and-how-they-differ/

These sources inform architecture categories only. TradePilot AI must independently define and validate its formulas, thresholds, caps and provider contracts.
