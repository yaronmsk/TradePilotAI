# TradePilot AI

Document:
UI / UX Specification

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
- AI_SPECIFICATION.md

---

# Purpose

This document defines the visual identity, user experience principles, layout standards, and interaction guidelines for TradePilot AI.

The objective is to provide a modern, professional, trustworthy investment application that emphasizes clarity over visual clutter.

---

# Design Philosophy

TradePilot AI is designed for investors.

The interface shall communicate:

- Professionalism
- Simplicity
- Transparency
- Confidence
- Trust

The application must avoid unnecessary visual effects, excessive animations, or gaming-style interfaces.

Information must always be more important than decoration.

---

# Visual Identity

Primary Style

Professional

Modern

Minimalistic

Premium

Financial

---

# Theme

Default Theme

Light Theme

Primary Background

Silver / Light Gray

Example

#F2F2F2

Cards

White

Rounded corners

Soft elevation

Minimal shadows

App Bar

Silver

Flat

Centered title

---

# Primary Colors

Background

Silver

Cards

White

Primary Accent

Blue Gray

Positive

Green

Negative

Red

Warning

Orange

Information

Blue

---

# Typography

Primary Font

Flutter default (initial release)

Future versions may adopt a dedicated premium font.

Text Hierarchy

Large Title

Page Title

Section Header

Body Text

Secondary Text

Caption

Numbers shall always remain highly readable.

---

# General Layout

Every page follows the same structure.

--------------------------------

App Bar

↓

Page Content

↓

Cards

↓

Bottom Navigation (future)

--------------------------------

Consistency across screens is mandatory.

---

# Dashboard Layout

The dashboard is the application's home screen.

Recommended layout:

Market Status

↓

Watchlist Summary

↓

AI Recommendation

↓

Historical Evidence

↓

Risk Summary

↓

Version Information

Each section is displayed as an independent card.

---

# Cards

Cards are the primary UI component.

Each card contains:

Title

Optional icon

Main information

Optional action

Cards should never appear visually crowded.

---

# Information Density

The interface should prioritize readability.

Preferred approach:

Less information

Better organization

Expandable details

Avoid overwhelming the user.

---

# Icons

Icons should be meaningful.

Examples

Market

Trending

AI

Psychology

History

Settings

Risk

Notification

Avoid decorative icons.

---

# Recommendation Presentation

Recommendations must be immediately understandable.

Recommendation levels:

Strong Buy

Buy

Hold

Sell

Strong Sell

The recommendation should be visually prominent.

---

# Confidence Representation

Confidence shall not rely solely on a percentage.

Instead, preference is given to historical evidence visualization.

Examples

Historical comparison graph

Agreement between AI engines

Historical outcome distribution

A numerical confidence percentage may appear only as supporting information.

---

# Historical Visualization

Historical analysis should emphasize visual comparison.

Possible visualizations include:

Timeline

Similarity graph

Historical outcome chart

Evidence distribution

The visualization should explain the recommendation rather than decorate the interface.

---

# AI Evidence

Every recommendation card shall include an explanation section.

The user should always understand:

Why

How

Based on what evidence

the recommendation was generated.

---

# User Interaction

Navigation should be intuitive.

The user should never require more than three interactions to reach any major function.

---

# Loading States

Whenever information is unavailable:

Display placeholders.

Avoid blank screens.

Display informative loading indicators.

---

# Error Handling

Errors should be understandable.

Example

Unable to retrieve market data.

Instead of

Unknown Error (500)

---

# Notifications

Notifications should be meaningful.

Examples

Recommendation changed

Historical analysis completed

Market reopened

Avoid excessive notifications.

---

# Accessibility

The application should support:

Readable font sizes

Color contrast

Large touch targets

Simple navigation

---

# Performance

The interface should feel responsive.

Target

Smooth scrolling

Minimal loading delays

No unnecessary animations

---

# Animation Philosophy

Animations should support usability.

Examples

Page transition

Card expansion

Loading indicator

Avoid decorative animations.

---

# Future Dark Theme

A dark theme is approved for future versions.

It is not part of the MVP.

---

# Mobile First

TradePilot AI is designed primarily for smartphones.

Tablet support should reuse the same design language.

Desktop support exists for development purposes.

---

# Platform Consistency

Android and iOS should provide the same user experience whenever possible.

Platform-specific behavior should only be adopted when it improves usability.

---

# UX Principles

Every screen should answer three questions immediately:

What am I looking at?

Why is this important?

What should I do next?

---

# Design Principles

TradePilot AI follows these principles:

Information before decoration.

Transparency before persuasion.

Professionalism before excitement.

Evidence before confidence.

Consistency before creativity.

---

# Success Criteria

A successful UI should allow a first-time user to:

Understand the recommendation.

Understand the supporting evidence.

Navigate without guidance.

Trust the presentation.

Understand that the application assists rather than predicts.

---

# Change Control

This document is governed by the project's Vision Freeze.

Any modification requires:

1. Explicit approval.
2. Version update.
3. Documentation update.