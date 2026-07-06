# TradePilot AI

Document:
AI Specification

Version:
1.0

Status:
Approved

Last Updated:
2026-07-06

Owner:
TradePilot AI

Related Documents:
- MASTER_SPECIFICATION.md
- FEATURE_SPECIFICATION.md

---

# Purpose

This document defines the principles, responsibilities, and operational behavior of the Artificial Intelligence system used by TradePilot AI.

This document intentionally avoids implementation details and instead focuses on functional behavior and product philosophy.

---

# AI Philosophy

TradePilot AI does **not** attempt to predict the future.

Its purpose is to provide statistically-supported investment recommendations by analyzing historical evidence and current market conditions.

Every recommendation must be explainable, transparent, and supported by evidence.

The AI assists investors in making better informed decisions.

The final investment decision always belongs to the user.

---

# Core Principles

The AI system shall always:

- Be transparent.
- Explain every recommendation.
- Present supporting evidence.
- Learn from historical outcomes.
- Never guarantee future performance.
- Never present itself as financial advice.
- Never claim certainty.

---

# Recommendation Philosophy

Recommendations represent the AI's evaluation of available evidence at a specific point in time.

Recommendations are advisory only.

Possible recommendation states:

- Strong Buy
- Buy
- Hold
- Sell
- Strong Sell

---

# AI Engines

TradePilot AI consists of two independent recommendation engines.

---

# Engine A
## Historical Evidence Engine

Purpose

Search historical market data for situations that resemble the current market.

Responsibilities

- Detect similar historical conditions.
- Compare technical patterns.
- Compare market environments.
- Compare indicator behavior.
- Evaluate historical outcomes.

Output

Historical recommendation.

Historical evidence score.

Historical comparison graph.

Historical explanation.

---

# Engine B
## Current Statistical Analysis Engine

Purpose

Analyze only the current market situation.

Responsibilities

- Analyze current candle structure.
- Analyze trend.
- Analyze technical indicators.
- Analyze statistical probabilities.
- Evaluate market momentum.

Output

Current recommendation.

Current statistical explanation.

Supporting indicators.

---

# Recommendation Modes

Users may choose one of the following modes.

Mode 1

Historical Evidence only.

Mode 2

Current Statistical Analysis only.

Mode 3

Combined Recommendation.

Combined mode displays the results of both engines together.

---

# Combined Recommendation

When enabled, both AI engines execute independently.

The application presents:

- Historical recommendation.
- Current statistical recommendation.

If both recommendations agree, the application shall indicate strong alignment.

If recommendations differ, both viewpoints shall be presented without hiding disagreement.

TradePilot AI favors transparency over forcing a single answer.

---

# Historical Evidence Visualization

TradePilot AI replaces a simple confidence percentage with historical evidence visualization whenever possible.

The application should display information such as:

- Number of similar historical situations.
- Historical outcome distribution.
- Historical success rate.
- Similarity level.
- Supporting historical graph.

The goal is to help users understand why the recommendation exists.

---

# Recommendation Explanation

Every recommendation must include an explanation.

Example topics include:

- Trend analysis.
- Historical similarities.
- Technical indicators.
- Market momentum.
- Risk considerations.

Recommendations without explanations are not permitted.

---

# AI Transparency

The AI must clearly distinguish between:

Observed Facts

Statistical Analysis

Historical Evidence

AI Interpretation

The user should always understand which information represents objective data and which represents AI reasoning.

---

# Recommendation Lifecycle

Each recommendation follows the following lifecycle.

1.

Collect market data.

↓

2.

Historical analysis.

↓

3.

Current statistical analysis.

↓

4.

Generate recommendation(s).

↓

5.

Generate explanation.

↓

6.

Display recommendation.

↓

7.

Record recommendation.

↓

8.

Monitor market outcome.

↓

9.

Evaluate recommendation quality.

↓

10.

Store learning results.

---

# AI Learning

TradePilot AI continuously evaluates previous recommendations.

The AI shall record:

- Recommendation date.
- Stock.
- Recommendation.
- Supporting evidence.
- Historical mode.
- Statistical mode.
- Market outcome.
- Recommendation accuracy.

This information supports continuous improvement.

---

# Learning Principles

The learning process must never alter historical records.

Historical recommendations remain immutable.

Learning occurs by evaluating historical performance over time.

This guarantees complete transparency.

---

# Historical Repository

TradePilot AI maintains a historical repository containing:

- Recommendations.
- Market snapshots.
- Supporting evidence.
- Final outcomes.
- Historical comparisons.

The repository serves three purposes:

- Replay Mode.
- Recommendation validation.
- Continuous learning.

---

# Replay Mode

Replay Mode allows users to revisit historical market situations.

The application shall reproduce:

- Market conditions.
- AI recommendation.
- Supporting evidence.
- Final market outcome.

Replay Mode is intended for:

- Education.
- Product demonstration.
- Building user trust.

---

# Confidence Representation

The application should avoid presenting a single confidence percentage as the primary indicator.

Instead, confidence should be represented through historical evidence whenever possible.

Examples include:

- Similar historical cases.
- Agreement between AI engines.
- Historical success frequency.
- Statistical consistency.

A numerical confidence value may still be displayed as supplementary information.

---

# AI Limitations

TradePilot AI cannot:

- Predict future market prices.
- Guarantee investment success.
- Eliminate investment risk.

The AI evaluates probabilities using available information.

---

# Ethical Principles

TradePilot AI shall:

- Avoid misleading statements.
- Clearly communicate uncertainty.
- Avoid exaggerated marketing language.
- Present balanced recommendations.
- Respect user autonomy.

---

# Legal Principles

TradePilot AI provides informational analysis only.

Recommendations are not financial advice.

The application assumes no responsibility for investment decisions made by users.

---

# Future AI Extensions

The following capabilities are approved for future versions:

- Improved historical similarity detection.
- Enhanced statistical models.
- Better explanation generation.
- More advanced learning algorithms.

These improvements shall not alter the core AI philosophy defined in this document.

---

# Change Control

This document is governed by the project's Vision Freeze.

Any modification requires:

1. Explicit approval.
2. Version update.
3. Documentation update.