# TradePilot AI — Personal Android Beta Fast-Track Roadmap

**Status:** Active development priority after v0.12.0  
**Decision date:** 2026-09-05  
**Baseline release:** v0.12.0 — Investor Strategy Brain  
**Baseline commit:** b2e358a  
**Next release:** v0.13.0 — Personal Android Beta  
**Target:** approximately 4–6 weeks at the current part-time development pace, with the first real-data Android build targeted earlier during the release.

## 1. Purpose

TradePilot AI has completed the brain-first phase through Trader, Swing and Investor.

The next priority is not to add another major intelligence layer.

The next priority is to make the validated intelligence useful on a personal Android device with real data as quickly and safely as possible.

The development philosophy changes from:

**Brain first → product later**

to:

**Frozen validated brain → thin live vertical slice → use it → improve from real evidence.**

This changes implementation order, not recommendation architecture.

The v0.12.0 Trader, Swing and Investor behavior remains the validated baseline.

## 2. Fast-track product goal

The v0.13.0 Personal Android Beta succeeds when:

1. TradePilot can be installed on the owner's Android phone.
2. A real U.S. equity can be selected.
3. Real authoritative market data is loaded.
4. Trader and Swing can analyze the real market data through the existing engines.
5. Investor can analyze the real fundamental/valuation data that is actually available.
6. Missing live inputs are marked unavailable rather than replaced with synthetic values.
7. Every strategy clearly identifies its data mode and freshness.
8. The existing recommendation, attribution and explainability architecture remains intact.
9. Manual analysis/refresh works reliably.
10. The app is explicitly experimental decision support and not presented as guaranteed investment advice.

Background monitoring and push notifications are not required to close v0.13.0.

## 3. Scope reduction for speed

The first live beta intentionally limits scope to:

- Android.
- U.S. listed equities.
- Manual analysis / refresh.
- One primary market-data integration.
- One minimal secure data gateway.
- Existing Trader / Swing / Investor brains.
- Existing dashboard and explainability UI.
- Existing local watchlist behavior where compatible.

The following do not block the first Personal Beta:

- iOS.
- public Play Store release.
- subscriptions/billing.
- multi-user accounts.
- portfolio optimization.
- AI Analyst / Mentor.
- advanced production Risk Engine.
- full real historical setup database.
- self-learning/reweighting.
- multiple redundant market-data vendors.
- broad international-market support.
- options/order-flow intelligence.
- final commercial UI redesign.

## 4. Permanent fast-track rules

### 4.1 Freeze major intelligence work

Do not add a major new intelligence feature if it delays the Personal Android Beta unless the missing capability is required for safe or meaningful real-world use.

Scoring changes are allowed only when real-data validation demonstrates a concrete defect.

### 4.2 Do not simplify the validated brains for integration convenience

Productization must not weaken, bypass or merge validated Trader, Swing or Investor semantics merely to make live-data integration easier.

### 4.3 Keep mock providers

Mock/synthetic providers remain first-class deterministic regression fixtures.

Live providers are added beside them behind the existing provider/domain boundaries.

### 4.4 Never silently mix mock data into live analysis

Live mode must not fall back to mock values.

If a real input is unavailable:

- mark it unavailable;
- reduce coverage/reliability as the strategy already defines;
- return a safe non-action state if required evidence is missing.

### 4.5 Explicit data-state contract

Every real strategy analysis must expose one of these states:

- **LIVE** — critical inputs are authoritative and current.
- **PARTIAL LIVE** — real analysis with one or more optional live inputs unavailable.
- **STALE** — required data exists but exceeds its freshness policy.
- **DATA ERROR** — required live data could not be obtained or validated.
- **SYNTHETIC** — development/test mode only.

Synthetic mode must never be mistaken for live analysis.

### 4.6 Protect API credentials

Production/personal-beta APKs must not embed raw paid-provider secrets.

A minimal server-side/serverless gateway should own external API credentials.

Local debug-only direct-provider access may exist temporarily only if clearly isolated and never committed with secrets.

### 4.7 Manual refresh before monitoring

Do not delay v0.13.0 to build background monitoring.

Manual real-stock analysis is the first usable milestone.

Monitoring and notifications follow in v0.14.0.

### 4.8 Real historical validation must be honest

Synthetic historical cases must not modify confidence in LIVE/PARTIAL LIVE analysis.

Until a real point-in-time historical dataset exists:

- live Historical Setup Validation is unavailable;
- historical confidence adjustment = 0;
- the UI explains why it is unavailable.

This is preferable to contaminating real recommendations with synthetic historical outcomes.

## 5. Data-provider strategy

### Primary candidate

**Twelve Data** is the current preferred first provider candidate because a single API can cover:

- U.S. real-time market data;
- intraday and daily historical OHLCV;
- company profile/corporate actions;
- earnings;
- standardized fundamentals on eligible plans;
- valuation/statistics;
- future WebSocket streaming.

This is a candidate, not an irreversible dependency.

TradePilot domain/provider interfaces must remain vendor-neutral.

### Authoritative U.S. filing fallback

**SEC EDGAR / data.sec.gov** is the preferred authoritative fallback/source for reported U.S. fundamentals because it exposes submissions and XBRL company facts without API-key authentication.

SEC integration may be used where it provides better data authority/cost tradeoffs than a commercial normalized fundamental endpoint.

### Provider decision gate

Before purchasing a paid plan or coding deep vendor-specific mappings:

1. verify AAPL real-time quote;
2. verify 1m/5m/1h/1D historical coverage required by Trader/Swing;
3. verify timestamps, timezone and adjusted/unadjusted semantics;
4. verify volume fields;
5. verify rate/credit limits;
6. verify required Investor statement fields;
7. verify valuation/statistics fields;
8. verify filing/availability timestamps where point-in-time use matters;
9. verify personal-use licensing for the Personal Beta;
10. estimate monthly cost;
11. confirm the provider can be replaced behind TradePilot interfaces.

If the commercial fundamentals tier is disproportionately expensive, use the market-data provider for Trader/Swing and SEC EDGAR for initial Investor reported fundamentals.

## 6. Minimal backend strategy

Do not build a full SaaS backend before Personal Beta.

Create only a **TradePilot Data Gateway** with responsibilities limited to:

1. protect API credentials;
2. request live provider data;
3. normalize/cache responses where useful;
4. expose stable TradePilot-oriented endpoints;
5. record source/freshness metadata;
6. later support scheduled monitoring and push notifications.

Do not block v0.13.0 on:

- accounts;
- billing;
- admin UI;
- cloud portfolio synchronization;
- social login;
- multi-user tenancy.

The gateway technology should be selected for fastest secure deployment and easy evolution into v0.14 monitoring/notifications.

## 7. v0.13.0 implementation batches

### Batch 0 — Fast-track / provider spike

Target: first few development sessions.

- Lock this roadmap.
- Test the primary candidate provider with AAPL.
- Record exact required endpoints and plan limitations.
- Decide the initial gateway technology.
- Define live-source/freshness metadata contracts.
- No recommendation scoring changes.

Acceptance:
- provider feasibility decision documented;
- one real AAPL request proven outside the app;
- no secrets committed.

### Batch 1 — Live-data foundation

- Add environment/data-mode selection.
- Add LIVE / PARTIAL LIVE / STALE / DATA ERROR / SYNTHETIC model.
- Add live market provider behind existing interfaces.
- Add minimal data gateway client.
- Add strict no-mock-fallback invariant for live mode.
- Add provider error/rate-limit/timezone parsing tests.

Acceptance:
- real quote/history can enter TradePilot domain models;
- mock tests remain deterministic.

### Batch 2 — Trader + Swing live vertical slice

- Real quote.
- Real intraday candles.
- Real daily/weekly history.
- Real historical baseline for Stock DNA where available.
- Existing Trader/Swing engines consume live normalized models.
- Surface source and freshness state.

Acceptance:
- real AAPL can run Trader and Swing without synthetic market data;
- missing external context is explicitly unavailable rather than mocked.

### Batch 3 — First Android live build

This batch is deliberately early.

- Produce/install Android APK.
- Configure secure gateway endpoint.
- Verify AAPL plus a small real-stock set.
- Manual refresh.
- Network/offline/error behavior sufficient for testing.

Goal:
**first genuine real-data TradePilot analysis on the owner's Android phone.**

Target:
approximately week 2 if provider/gateway integration is straightforward.

### Batch 4 — Investor live core slice

Connect only what is required for a meaningful first Investor analysis.

Priority:

- Growth.
- Profitability & Quality.
- Financial Strength.
- Valuation.
- Capital Allocation & Dilution.

Revisions, Ownership & Positioning and other optional/context data may remain unavailable initially.

Rules:

- maintain core-family breadth gate;
- maintain mandatory Valuation gate;
- unsupported/missing families remain unavailable;
- never substitute synthetic fundamentals in live mode;
- preserve point-in-time availability discipline.

### Batch 5 — Partial-live safety and quality

- freshness policies;
- stale-data handling;
- rate-limit handling;
- provider outage handling;
- malformed/partial response handling;
- source labels;
- data timestamp visibility;
- safe strategy non-action behavior;
- live Historical Validation disabled until real historical cases exist.

### Batch 6 — Personal Android Beta acceptance

Required:

- Android install accepted.
- Real U.S. symbols work.
- Trader real-data path accepted.
- Swing real-data path accepted.
- Investor real/partial-live path accepted.
- data-state/freshness labels accepted.
- no synthetic fallback in live mode.
- analyzer/tests clean.
- release build accepted.
- personal-use disclaimer visible/appropriate.
- documented known limitations.

Release:
**v0.13.0 — Personal Android Beta**

## 8. Estimated timeline

At the current part-time development pace:

- **Week 1:** provider spike + gateway + live quote/history foundation.
- **Week 2:** Trader/Swing real-data slice + first Android live build.
- **Week 3:** Investor real core fundamentals/valuation.
- **Week 4:** partial-live/staleness/error handling + broader symbol testing.
- **Week 4–6:** v0.13.0 Personal Android Beta acceptance.

These are planning targets, not guarantees. Provider access, licensing, unexpected payload/data-quality issues and Android deployment constraints may change the schedule.

## 9. After Personal Beta

### v0.14.0 — Monitoring & Notifications

Estimated 3–5 additional weeks.

- monitored-stock configuration;
- scheduled server-side analysis;
- meaningful-change detection;
- alert de-duplication/cooldowns;
- BUY/SELL parity;
- push notifications;
- why-this-alert explanation;
- notification history.

Trader monitoring should not rely on Android periodic background execution as the long-term primary scheduler.

### v0.15.0 — Product hardening

Estimated 4–8 additional weeks.

- persistence;
- settings;
- reliability;
- cache policy;
- security hardening;
- privacy;
- recovery/error UX;
- watchlist improvements;
- basic operational telemetry;
- Android update workflow.

### Later v0.x — Resume intelligence expansion

Resume deferred intelligence only after real usage and data quality are producing meaningful feedback.

### v1.0.0

Target remains the validated multi-strategy production-readiness milestone, not merely “three brains exist.”

A public/commercial release still requires provider licensing, production operations, legal/privacy work, final security review, commercial UI/onboarding and broader release acceptance.

## 10. Deferred Intelligence Backlog — postponed, not rejected

These ideas remain part of the project:

- production Risk Engine;
- real point-in-time Historical Setup database;
- walk-forward/out-of-sample calibration;
- stock-specific threshold calibration;
- evidence effectiveness tracking;
- safe learning/reweighting after validation;
- deeper Investor peer/sector normalization;
- stronger macro-sensitivity calibration;
- authoritative revisions history;
- authoritative institutional/insider positioning;
- long-term technical/context refinement;
- advanced event/news intelligence;
- AI Analyst / Mentor grounded in deterministic output;
- richer decision helpers;
- portfolio/risk intelligence;
- future options/flow intelligence where data quality/licensing justify it;
- commercial UI redesign.

Every deferred item should be reconsidered using real Personal Beta observations rather than synthetic-fixture attractiveness alone.

## 11. Success philosophy

The shortest path is not to finish every future capability before using TradePilot.

The shortest safe path is:

**Real data → one real stock → existing brain → Android → use it → observe failures → fix what matters → automate monitoring → resume intelligence.**

That sequence is now the authoritative post-v0.12 development priority.
