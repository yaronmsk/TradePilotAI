# TradePilot AI v0.9 Refinement — Weighted Historical Scoring

## Goal

Historical setup measurements must not be treated as equally reliable or equally informative.
This refinement makes the historical confidence adjustment explicit, weighted, testable, and explainable.

## Historical outcome weights

The historical outcome score uses four normalized dimensions:

| Dimension | Weight | Purpose |
|---|---:|---|
| Difference vs context-matched stock baseline | 40% | Highest-priority test of whether matched setups add information beyond background market drift. |
| Directional follow-through | 20% | Measures how often similar setups moved in the current recommendation direction. |
| Normalized outcome magnitude | 20% | Measures whether the typical move was meaningful relative to the stock behavior type. |
| Excursion quality | 20% | Rewards favorable movement with limited adverse movement and penalizes historically painful setups. |

The four outcome weights sum to 100%.

## Reliability is not another vote

Effective sample depth and average match quality are applied after the weighted outcome score.
They do not add points of their own.

TradePilot calculates:

- Effective-sample reliability
- Match-quality reliability
- Applied reliability = the weaker of the two

This weakest-link rule is deliberately conservative. A large sample of weak matches and a tiny sample of excellent matches should both have limited historical influence.

## Anti-drift gate

Historical validation cannot increase confidence merely because a broad market drifted in the same direction.
For a positive historical confidence adjustment, matched cases must beat both:

1. A 50/50 directional baseline, and
2. The context-matched same-stock baseline.

## Confidence impact

Historical validation remains an external confidence-validation layer and does not change recommendation direction by itself.

Final historical impact remains bounded to ±8 confidence points.

## Explainability

The Historical Setup Check → Historical details section exposes:

- Each outcome dimension and its configured weight
- Its normalized support/opposition score
- Weighted historical quality
- Effective-sample reliability
- Match-quality reliability
- Applied reliability

The UI therefore reflects the same mathematics used by the engine rather than decorative percentages.

## Future real-data extension

When real historical setup data is available, add time-segment / out-of-sample stability as an additional reliability gate. Do not fake this metric while using synthetic development history.
