# Release 0.5 — Recommendation Insight UX Refinement

## Goal

Keep the full Consensus Engine intelligence while making its default presentation understandable to an end user.

## Problem

The original Trader Brain Summary exposed six implementation-oriented boxes directly:
- Direction
- Confidence
- Agreement
- Conflict
- Independent Families
- Family Coverage

The metrics are useful internally, but the default presentation requires too much interpretation and makes the user learn the engine before understanding the recommendation.

## User-facing design

The strategy-specific card is now `<Strategy> Recommendation Insight` and presents only:
- Signal Strength — how strongly the combined evidence leans bullish or bearish.
- Confidence — how much trust the engine places in the conclusion after considering strength, coverage, alignment and reliability.
- Signal Alignment — whether independent evidence groups agree.

Each metric has an info button.

A `Why this confidence?` section generates a deterministic plain-English explanation from the evidence-group consensus.

## Technical drill-down

`How was this calculated?` keeps the detailed engine metrics available without cluttering the default dashboard:
- Bullish evidence
- Bearish evidence
- Evidence groups
- Evidence-group coverage
- Provider coverage
- Average reliability
- Internal agreement
- Conflict level
- Per-group direction and signal count
- Confidence warnings

## Rule

The UI simplification does not remove or weaken any consensus calculation. It changes only how the result is explained. Confidence must never be presented as a guaranteed probability of profit.
