# TradePilot AI
# Master Specification

| Property | Value |
|----------|-------|
| Version | 1.0 |
| Status | Vision Freeze |
| Project | TradePilot AI |
| Owner | Yaron Moshkovitz |
| Technical Architect | ChatGPT |
| Last Updated | July 2026 |

---

# Table of Contents

1. Vision
2. Mission
3. Product Principles
4. Product Scope
5. Functional Requirements
6. AI Architecture
7. User Interface
8. Technical Architecture
9. Security
10. Legal
11. Business Model
12. Development Process
13. Roadmap
14. Future Scope

---

# 1. Vision

TradePilot AI is an evidence-based investment decision support platform.

The platform assists investors by evaluating market conditions using statistical analysis, historical evidence and explainable artificial intelligence.

TradePilot AI does **not** predict future prices.

Instead, it provides transparent recommendations together with the evidence that supports them.

Our goal is to become one of the most trusted investment assistants available.

---

# 2. Mission

Help investors make better informed decisions.

Not decisions for them.

TradePilot AI exists to improve decision quality through transparency, measurable evidence and continuous learning.

---

# 3. Product Principles

The following principles are permanent.

### P-001

Never claim to predict the future.

### P-002

Every recommendation must be explainable.

### P-003

Every recommendation must present measurable evidence.

### P-004

Always present both supporting and opposing evidence.

### P-005

The investor makes the final decision.

### P-006

When confidence is insufficient, recommend WAIT.

### P-007

Transparency is more important than complexity.

### P-008

Long-term trust is more important than marketing.

---

# 4. Product Scope

Initial platform:

- Android

Future platforms:

- iOS
- Web

Target users:

- Retail investors
- Swing traders
- Position traders
- Long-term investors

---

# 5. Functional Requirements

The initial MVP shall include:

## Watchlist

Maintain multiple watchlists.

---

## Stock Dashboard

Display detailed information for every selected stock.

---

## Recommendation

Possible recommendations:

- BUY
- SELL
- WAIT

---

## Evidence Panel

Display:

- Supporting evidence
- Opposing evidence
- Current values
- Historical averages
- Dynamic thresholds

---

## Historical Comparison

Compare the current market situation with previous similar situations.

---

## Recommendation History

Store recommendation history for future comparison.

---

## Confidence History

Display historical confidence evolution using graphs.

---

## Replay Mode

Replay historical market sessions.

Hide future candles.

Allow users to compare their decisions against TradePilot AI.

---

## Dynamic Thresholds

Thresholds shall automatically adapt according to:

- Stock
- Timeframe
- Volatility
- Historical behavior

---

## Historical Recording

Store analysis history for:

- Learning
- Replay
- Statistics
- Performance evaluation

---

## Notifications

Future capability.

Notify users when important recommendation changes occur.

---

# 6. AI Architecture

TradePilot AI is composed of multiple analytical engines.

## Historical Similarity Engine

Compares current situations against historical market situations.

---

## Market Structure Engine

Analyzes:

- Trend
- Breakouts
- Support
- Resistance
- Candlestick patterns

---

## Indicator Engine

Analyzes:

- RSI
- MACD
- EMA
- SMA
- Bollinger Bands
- ATR
- ADX
- Volume
- OBV

---

## Risk Engine

Calculates:

- Risk
- Volatility
- Drawdown
- Risk / Reward

---

## Learning Engine

Continuously measures:

- Win rate
- Accuracy
- False positives
- False negatives
- Historical performance

---

## Recommendation Modes

Users may choose:

- Committee Recommendation
- Historical Recommendation
- Current Market Recommendation
- Indicator Recommendation
- Custom weighted recommendation

---

# 7. User Interface

Design goals:

- Modern
- Professional
- Premium appearance

Theme:

Silver

Presentation philosophy:

- Tables preferred over gauges.
- Numbers preferred over decorative graphics.
- Graphs only when useful.

---

## Dashboard

Contains:

- Watchlist
- Recommendation
- Evidence panel
- Risk panel
- Historical comparison
- Recommendation history
- Confidence history graph

---

## Evidence Table

Every evidence item displays:

- Current value
- Historical average
- Dynamic threshold

Exceptional values shall be highlighted using colors.

Every row shall contain an information icon explaining:

- Definition
- Importance
- Interpretation

---

# 8. Technical Architecture

Frontend:

Flutter

Backend:

FastAPI

Containerization:

Docker

Source Control:

Git

Hosting:

Initially local.

Future cloud deployment.

---

# 9. Security

Security is considered a core requirement.

Requirements:

- Private Git repository
- Secure authentication
- HTTPS
- No secrets inside source code
- Principle of least privilege

---

# 10. Legal

TradePilot AI is an informational platform.

It does not provide financial advice.

Users remain solely responsible for investment decisions.

Recommendations are statistical evaluations.

No future performance is guaranteed.

---

# 11. Business Model

Free Version

- Watchlists
- Basic analysis

Premium Version

- AI Committee
- Replay Mode
- Historical intelligence
- Advanced analytics
- Cloud synchronization

---

# 12. Development Process

Every feature follows:

1. Specification
2. Design
3. Implementation
4. Testing
5. Documentation
6. Git Commit

The Master Specification is the single source of truth.

---

# 13. Roadmap

Phase 1

Project Foundation

Phase 2

Dashboard

Phase 3

Market Data

Phase 4

Recommendation Engine

Phase 5

Evidence Panel

Phase 6

Historical Database

Phase 7

AI Committee

Phase 8

Replay Mode

Phase 9

Cloud

Phase 10

Public Beta

---

# 14. Future Scope

The following capabilities are planned for future releases:

- iOS support
- Web application
- Portfolio management
- Additional AI engines
- Cloud synchronization
- Professional analytics
- Enterprise capabilities

---

# Vision Freeze

This document represents the agreed vision for the initial development of TradePilot AI.

New ideas are intentionally excluded from Version 1.0 to maintain development focus.

Changes to this document shall occur only when implementation reveals a necessary improvement or after completion of a planned milestone.

---

**TradePilot AI Motto**

> **Evidence Before Action**
