# TradePilot AI

Document ID:
TP-006

Document:
Development Guidelines

Version:
1.0

Status:
Approved

Last Updated:
2026-07-06

Owner:
TradePilot AI

Related Documents:
- TP-000 Documentation Standard
- TP-001 Master Specification
- TP-005 Architecture Specification

---

# Purpose

This document defines the software development standards and engineering practices used throughout the TradePilot AI project.

Its objective is to ensure consistency, maintainability, readability and long-term scalability.

---

# Development Philosophy

TradePilot AI is built according to the following principles:

- Build incrementally.
- Keep the application working after every change.
- Prefer simplicity over unnecessary complexity.
- Write maintainable code.
- Document important decisions.
- Deliver small improvements continuously.

---

# Vision Freeze

The product follows the Vision Freeze defined in the Master Specification.

During MVP development:

- No new features shall be introduced unless explicitly approved.
- Development shall focus on implementing approved functionality.
- Ideas identified during implementation shall be documented separately and evaluated after the MVP.

---

# General Development Workflow

Every feature follows the same lifecycle.

1. Specification
2. Design
3. Implementation
4. Testing
5. Documentation
6. Git Commit
7. Push to GitHub

A feature is considered complete only when all seven steps have been completed.

---

# Source Control

Git is the official source control system.

GitHub is the official repository.

---

# Branch Strategy

Main Branch

Purpose

Stable code.

Contains only completed milestones.

---

Develop Branch

Purpose

Daily development.

All implementation work is performed here.

---

# Commit Strategy

Commits should be:

- Small
- Focused
- Meaningful

Avoid combining unrelated changes into the same commit.

---

# Commit Naming

Examples

docs: update AI specification

feat: implement dashboard layout

feat: add watchlist screen

fix: correct recommendation calculation

refactor: simplify dashboard controller

test: add dashboard widget tests

---

# Project Structure

TradePilotAI/

backend/

mobile/

docs/

assets/

scripts/

tools/

The project structure shall remain consistent.

---

# Flutter Architecture

The Flutter application follows a feature-based architecture.

Each feature owns its own:

- Pages
- Controllers
- Widgets
- Models (future)
- Services (future)

Shared components belong in the core module.

---

# Folder Ownership

Each folder has a single responsibility.

app/

Application initialization.

core/

Shared functionality.

features/

Business features.

docs/

Project documentation.

backend/

Server implementation.

---

# Code Organization

Every source file should have a clear responsibility.

Avoid large files.

Prefer small focused classes.

Business logic shall never be placed inside UI widgets.

---

# Code Style

The project follows the official Dart formatting guidelines.

Rules

Meaningful names

Consistent formatting

Small methods

Readable code

Avoid unnecessary comments.

Good code should explain itself whenever possible.

---

# Naming Conventions

Classes

PascalCase

Example

DashboardController

---

Methods

camelCase

Example

loadRecommendations()

---

Variables

camelCase

Example

currentRecommendation

---

Constants

camelCase (following Dart conventions)

Example

defaultRefreshInterval

---

Files

snake_case

Example

dashboard_controller.dart

---

# Documentation

All important functionality shall be documented.

Major architectural decisions shall be recorded.

The Master Specification remains the project's primary source of truth.

---

# Error Handling

Errors shall be:

Handled

Logged

Presented clearly to the user

Unexpected application crashes should be avoided whenever possible.

---

# Testing

Every implemented feature should be tested before committing.

Testing includes:

Application launch

Feature behavior

Regression verification

Additional automated tests will be introduced as the project evolves.

---

# Performance

Performance should be considered during implementation.

Avoid unnecessary rebuilds.

Avoid duplicated calculations.

Avoid unnecessary memory usage.

Optimization should never reduce readability without measurable benefit.

---

# Security

Security considerations shall be part of every implementation.

Sensitive information must never be:

Hardcoded

Committed to Git

Displayed in logs

Security requirements are further defined in the Security Specification.

---

# Documentation Updates

Whenever functionality changes:

1. Update the implementation.
2. Update the relevant documentation.
3. Commit both together whenever practical.

Documentation should accurately reflect the current implementation.

---

# Definition of Done

A task is considered complete only if:

✓ Code implemented

✓ Code reviewed

✓ Application builds successfully

✓ Feature tested

✓ Documentation updated

✓ Git committed

✓ Git pushed

---

# Revision History

| Version | Date | Author | Description |
|----------|------------|----------------|---------------------------|
| 1.0 | 2026-07-06 | TradePilot AI | Initial version |

---

# Approval

Status:
Approved

Approved By:
Project Founder

Architecture Owner:
TradePilot AI

---

# Change Control

This document follows the TradePilot AI Documentation Standard.

Changes require:

1. Approval.
2. Version update.
3. Git commit.