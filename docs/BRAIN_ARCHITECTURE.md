# TradePilot AI Brain Architecture

Version: 0.12.0 Investor Strategy Brain architecture scope
Status: Living design — v0.12.0 Batch 2 Growth + Profitability/Quality validated

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
- No Clear Direction for Swing
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
- Sentiment

Reserved future families:
- Fundamentals
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
- Market Breadth → Market Context
- News Sentiment → Sentiment

Event Risk is not an evidence family. It is a confidence-only external modifier.

Historical Setup Validation is not an evidence family. It is a bounded post-consensus confidence overlay.

De-duplication example:
- Candle Trend, EMA Structure and Multi-Timeframe Trend refine one Trend conclusion rather than creating three independent votes.
- RSI and MACD refine one Momentum conclusion.
- Relative Volume and Volume Confirmation refine one Participation conclusion.
- VWAP and Support/Resistance refine one Price Structure conclusion.
- Market & Sector Context and Market Breadth refine one Market Context conclusion.

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

## v0.11 strategy-aware analysis policy

v0.11.0 introduces a strategy-aware policy layer before existing evidence providers are reused for Swing.

Conceptual flow:

Strategy Type
→ Strategy Analysis Policy
→ Provider applicability
→ Strategy-specific parameters / lookbacks / thresholds
→ Evidence provider
→ Strategy-aware contextual adjustment
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy recommendation policy
→ Confidence-only modifiers
→ Strategy-specific presentation and explainability

The purpose is to share provider implementations only when the underlying calculation is genuinely reusable while allowing Trader and Swing to use different:

- Applicability.
- Parameters.
- Lookbacks.
- Thresholds.
- Reliability.
- Weight.
- Semantic role.
- Direction behavior.
- Confidence behavior.
- Risk / entry-quality behavior.

An existing provider may therefore be:

- Enabled unchanged.
- Enabled with Swing calibration.
- Used as context/confidence/entry-quality only.
- Excluded from Swing.
- Deferred until the required data quality exists.

Swing must not be implemented as Trader logic running on slower candles.

Detailed Swing evidence and capability decisions are defined in:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

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
- Strategy-role hierarchy with selectable strategy primary intervals and automatically selected confirmation/backdrop intervals.
- Higher-timeframe trend remains inside the Trend family.
- Relative strength vs broad market and sector.
- Market Context as an independent evidence family.

### v0.8 — Advanced Trader evidence
Implemented:
- EMA Structure inside Trend.
- MACD Momentum inside Momentum.
- Volume Confirmation inside Participation.
- Analysis-window VWAP Position inside Price Structure.
- ATR-normalized local Support & Resistance inside Price Structure.
- ATR-normalized Price Extension inside Volatility.
- Evidence UI grouping by evidence family.

Deferred intentionally:
- ADX until historical validation shows incremental value.
- Bollinger Bands until evidence shows incremental value.
- True session VWAP until reliable session boundaries exist.

### v0.9 — Historical Setup Validation
- Setup fingerprint from de-duplicated family state + Stock DNA + market context.
- Similar historical case matching.
- Follow-through vs context-matched same-stock baseline.
- Bounded confidence-only adjustment.

### v0.10 — Event / broader-environment context
- Earnings calendar/risk.
- News and sentiment.
- Market breadth/regime.
- Volatility/risk regime.

### v0.10.1 — Explainability & Bidirectional Audit
- Reusable `MetricExplainability`.
- Explicit semantic roles.
- Complete production-evidence explainability.
- Individual Analysis Context explainability.
- Historical Validation ±8 confidence boundary.
- Event Risk 12-point maximum penalty.
- Automated explainability and behavioral invariants.

### v0.11.0 — Swing Strategy Brain
- Strategy-aware evidence/applicability policy.
- Evidence-by-evidence Swing calibration.
- Swing timeframe/context orchestration.
- Swing-specific Historical Setup Validation horizon.
- Swing recommendation policy.
- Batch 9A Strategy Summary activation and selected-strategy presentation integration.
- Human-readable Swing cards and Batch 9B presentation-only Decision Helpers (`Entry Quality`, `Price Stretch`, `Structure Watch`).
- Individual info paths for every Swing analytical input.
- Direction attribution reconciled to 100% of active post-family-cap influence.
- Confidence attribution kept separate from directional attribution.
- Trader and Swing presentation resolve from independent cached recommendation states.
- Swing Decision Helpers are downstream presentation summaries only: they consume already-computed typed evidence, do not enter the Consensus Engine and cannot add direction/confidence influence.
- Investor remains unavailable until v0.12.0.

### v0.12.0 — Investor Strategy Brain
- Growth.
- Profitability / Quality.
- Financial Strength.
- Valuation.
- Revisions.
- Long-term fundamental context.

### v1.0.0 — Validated Multi-Strategy Milestone
- Trader implemented and validated.
- Swing implemented and validated.
- Investor implemented and validated.
- Strategy-specific recommendations coexist cleanly.

### v1.x — Historical calibration + AI Analyst
- Real historical setup/outcome storage.
- Walk-forward / out-of-sample calibration.
- Evidence effectiveness by stock and regime.
- AI explanations grounded in deterministic evidence and validated history.

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

v0.10.1 makes explainability a domain-level architectural contract.

`MetricExplainability` classifies each user-facing analytical metric as:

- **Directional/evaluative** — may affect directional interpretation and must describe supportive and opposing outcomes where mathematically meaningful.
- **Confidence/risk-only** — may alter confidence or risk within an explicit bound but cannot create Buy/Sell direction.
- **Context/configuration** — describes analysis state/configuration and must not manufacture directional meaning.

Reusable explanation content can expose:
- What the metric means.
- How it is calculated.
- Why it matters.
- Supportive interpretation.
- Opposing interpretation.
- Neutral interpretation.
- Recommendation impact.
- Explicit bounded impact.
- Limitations.

Production `EvidenceKind` values are covered by a central explainability catalog.

Trader Analysis Context has a separate complete catalog covering all seven displayed metrics.

Architecture tests enforce completeness and semantic-role invariants.

Permanent confidence-only boundaries:
- Event Risk cannot increase confidence, cannot create Buy/Sell direction and is hard-capped at a 12-point confidence penalty.
- Historical Setup Validation cannot alter evidence-derived direction or evidence confidence and is hard-capped at ±8 final-confidence points.

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

The Consensus Engine emits exact post-de-duplication attribution alongside direction and confidence outputs.

Each evidence family receives:

- Signed direction-impact value.
- Confidence-contribution value.

Provider-level values must reconcile to the family total while preserving the family cap.

### User-facing direction attribution

For user-facing direction percentages, active absolute directional influence is normalized into a 100% basis only after:

- Strategy-specific weighting.
- Provider reliability.
- Contextual adjustment.
- Signal magnitude.
- Evidence-family aggregation.
- Family caps.
- Correlation de-duplication.

Therefore the displayed percentage represents actual current-case influence rather than configured base weight.

The active family direction basis must reconcile to 100%.

A family with no active directional contribution is excluded from the denominator.

Provider percentages shown inside a family must reconcile to that family's capped contribution.

Supportive and opposing contributions remain explicitly identified.

### Confidence attribution

Confidence attribution remains separate from directional attribution.

Evidence-derived confidence should explain:

- Provider coverage.
- Independent family coverage.
- Signal alignment.
- Conflict.
- Reliability.
- Family confidence contribution.

Confidence-only modifiers remain explicit point adjustments.

Examples:

- Event Risk: negative confidence points only, maximum -12.
- Historical Setup Validation: bounded ±8 confidence points.

These modifiers are never normalized into the directional 100% basis.

Confidence remains model confidence, not probability of profit.

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

`RecommendationContextService` loads a replaceable `ExternalContextProvider` alongside multi-timeframe stock/benchmark data. The current mock provider returns Market Breadth, Event Risk and News Sentiment profiles.

- Market Breadth → `MarketBreadthEvidenceProvider` → `EvidenceFamily.marketContext`.
- News Sentiment → `NewsSentimentEvidenceProvider` → `EvidenceFamily.sentiment`.
- Event Risk → `EventRiskConfidenceAdjuster` → confidence modifier only, capped at 12 points.

This role separation is intentional: breadth is related to existing market context, news can carry independent direction when data quality is sufficient, and scheduled-event proximity represents uncertainty/risk rather than direction.

## v0.10.1 explainability architecture

The explainability layer is shared across production evidence, Analysis Context and Historical Setup Validation.

The UI renders this contract through reusable explainability content/dialog components rather than embedding metric semantics directly into individual widgets.

Production safeguards are enforced in both metadata and behavior:

- Missing production evidence explainability fails architecture tests.
- Missing Analysis Context explainability fails architecture tests.
- Directional/evaluative metrics require both supportive and opposing interpretations where meaningful.
- Context/configuration metrics are not forced into artificial directionality.
- Event Risk remains confidence/risk-only and cannot be configured beyond its 12-point maximum penalty.
- Event Risk cannot create a positive confidence bonus.
- Historical Setup Validation remains confidence/risk-only and is defense-in-depth capped to ±8 at the final adjustment layer.
- Evidence-family de-duplication remains unchanged.
- Direction influence and confidence contribution remain separate concepts.

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


## v0.12 Investor architecture scope

The single future `fundamentals` family is intentionally insufficient for Investor because it would de-duplicate independent economic questions.

Proposed core families: Growth, Profitability & Quality, Financial Strength, Valuation, Revisions, Competitive Durability, and Capital Allocation & Dilution.

Shared/context concepts: long-horizon Market Context, low/capped long-term Trend, persistent/material Sentiment, and a proposed Ownership & Positioning family.

Actionable Investor recommendations require core-fundamental breadth. Technical, macro, sentiment and positioning context cannot satisfy that gate alone.

Global Market & Macro Context measures observable regimes plus stock-specific sensitivity; it is not an opaque global-sentiment score and cannot create Investor BUY/SELL by itself.

`Market Expectations` / `Expectations Gap` is a downstream zero-vote synthesis of already-counted evidence and therefore adds no direction/confidence influence.

Detailed contract: `docs/INVESTOR_STRATEGY_BRAIN_V0_12.md`.

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
