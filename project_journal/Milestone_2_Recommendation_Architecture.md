# Milestone 2 - Recommendation Architecture

Date

2026-07-07

Goal

Design the architecture of the recommendation engine before implementing business logic.

Major Decisions

- Feature-first architecture.
- Shared widgets moved to shared/.
- Recommendation moved into its own feature.
- Introduced the Evidence Framework.
- Every recommendation must be explainable.
- Recommendation explanation must be user-facing.
- Evidence is evaluated relative to the stock's historical behavior.
- Recommendation timeframe for MVP is 5-minute candles.
- Score represents evidence strength rather than recommendation direction.
- Evidence Providers are independent and coordinated by the Evidence Engine.

Next Milestone

Implement the Evidence Framework and the first Evidence Provider.