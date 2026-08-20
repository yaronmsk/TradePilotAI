# TradePilot AI v0.9 — Context-Matched Historical Baseline Refinement

Date: 2026-08-21
Status: Development / Validation

## Purpose

Make Historical Setup Validation compare like with like and make the UI explain exactly what is being compared.

## Similar historical setups

A historical setup may influence the analog result only when it uses the same strategy, primary analysis interval, and Stock Profile as the current stock. Stock Profile is now a hard eligibility gate, not a small similarity bonus.

After that gate, TradePilot scores similarity across independent evidence-group direction/strength, volatility regime, Market Environment and Relative Strength. Same-symbol matches may receive a modest statistical-weight preference, but other symbols are allowed only when they share the current Stock Profile.

## Current-stock comparison baseline

The previous unconditional/control return list has been replaced by structured historical observations from the current stock.

A comparison observation is eligible only when it matches:

- current symbol;
- strategy;
- primary analysis interval;
- Stock Profile;
- volatility regime; and
- Market Environment.

The comparison selector deliberately does **not** require today's evidence-family pattern. Its purpose is to estimate what the stock usually did under comparable surrounding conditions without selecting for the specific setup being validated.

This creates the intended comparison:

`similar setup follow-through` versus `same-stock follow-through under comparable surrounding conditions`.

## User-facing wording

The main Historical Setup Check now presents:

- `Based on N similar cases • X% match quality`
- `Similar historical setups: Y% follow-through`
- a plain-English explanation that these setups come from the current stock and other stocks with the same Stock Profile;
- `<SYMBOL> under comparable conditions: Z% follow-through`
- a plain-English explanation of the same-stock comparison group;
- `Historical Difference: +/-N% points`; and
- `Confidence effect: +/-N.N points`.

The word `control` is no longer exposed in the normal UI.

## Conservative data rule

If fewer than 12 context-matched same-stock comparison observations are available, Historical Setup Validation is treated as limited data and cannot adjust confidence.

## Development-data limitation

The mock provider still uses synthetic historical outcomes. This refinement validates the architecture and selection logic only. Real-world performance claims require a real historical data provider and out-of-sample validation.
