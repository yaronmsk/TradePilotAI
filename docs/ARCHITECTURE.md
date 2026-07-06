# TradePilot AI

Document:
Architecture Specification

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
- UI_UX_SPECIFICATION.md

---

# Purpose

This document defines the overall software architecture of TradePilot AI.

Its purpose is to ensure scalability, maintainability, security and clean separation of responsibilities throughout the lifetime of the project.

This document describes the logical architecture rather than implementation details.

---

# Architectural Principles

TradePilot AI shall be designed according to the following principles:

- Separation of concerns
- Modular architecture
- Feature-based organization
- Security by design
- Cloud-first architecture
- AI independence
- Testability
- Scalability

---

# High Level Architecture

+---------------------+
|   Mobile App        |
| (Flutter)           |
+----------+----------+
           |
           | HTTPS REST API
           |
+----------v----------+
| Backend API         |
| (Python/FastAPI)    |
+----------+----------+
           |
     +-----+------+
     |            |
+----v----+  +----v----+
|Database |  |AI Engine|
+---------+  +---------+

---

# Components

## Mobile Application

Technology

Flutter

Responsibilities

- User Interface
- Authentication
- Watchlist Management
- Recommendation Presentation
- Local Cache
- Settings
- Secure Communication

The mobile application contains no business logic related to AI.

---

## Backend

Technology

Python

FastAPI

Responsibilities

- Authentication
- Market data aggregation
- Recommendation requests
- Historical storage
- AI orchestration
- Security
- User management

The backend is the single source of truth.

---

## AI Layer

Purpose

Generate explainable investment recommendations.

Responsibilities

- Historical analysis
- Statistical analysis
- Recommendation generation
- Explanation generation
- Recommendation evaluation

The AI layer is independent from the user interface.

---

## Database

Purpose

Persistent storage.

Stores

- Users
- Watchlists
- Recommendations
- Historical records
- Replay data
- AI evaluation history
- Configuration

---

# Cloud Architecture

The backend and database are hosted in the cloud.

Benefits

- Centralized updates
- Cross-device synchronization
- Improved security
- Reduced device storage
- Scalability

Local development may temporarily use a personal computer before cloud deployment.

---

# Mobile Folder Structure

lib/

app/

core/

features/

assets/

Each feature owns its own screens, controllers and widgets.

No feature should directly depend on another feature.

Shared functionality belongs in the core module.

---

# Feature Architecture

Each feature follows the same structure.

feature/

page.dart

controller.dart

widgets/

services/ (future)

models/ (future)

This promotes consistency throughout the project.

---

# Layer Responsibilities

Presentation Layer

Responsible only for UI.

Business Layer

Responsible for application logic.

AI Layer

Responsible for recommendations.

Data Layer

Responsible for storage and retrieval.

Infrastructure Layer

Responsible for external services.

Each layer communicates only through well-defined interfaces.

---

# Communication

All communication between the mobile application and backend shall use HTTPS.

The mobile application never accesses the database directly.

All requests pass through the backend API.

---

# Data Flow

User Action

↓

Mobile UI

↓

Backend API

↓

AI Analysis

↓

Database

↓

Backend Response

↓

Mobile UI

---

# Offline Strategy

The application shall support limited offline functionality.

Examples

Previously viewed recommendations

Watchlist

Cached configuration

AI analysis requires server connectivity.

---

# Scalability

The architecture shall support:

Thousands of users

Future AI improvements

Additional recommendation engines

Future web application

Future enterprise deployment

without major redesign.

---

# Error Handling

Errors shall be handled at every layer.

Presentation

Friendly user messages.

Backend

Structured API responses.

Database

Transaction safety.

AI

Graceful failure with explanation.

---

# Logging

Application logging shall be divided into:

Application Logs

Security Logs

AI Logs

System Logs

Sensitive information must never appear in logs.

---

# Configuration

Configuration values shall never be hardcoded.

Examples

API URLs

Secrets

Tokens

Environment settings

Different environments shall be supported:

Development

Testing

Production

---

# Security Architecture

Authentication shall occur through the backend.

The mobile application never stores sensitive credentials in source code.

All secrets shall remain server-side whenever possible.

---

# Deployment Strategy

Development

Local workstation.

Testing

Private cloud environment.

Production

Cloud infrastructure.

Deployment shall not require changes to application source code.

---

# Future Extensibility

The architecture shall support future additions including:

Additional AI engines

Broker integrations

Advanced analytics

Premium subscription features

without requiring architectural redesign.

---

# Architectural Rules

The following rules are mandatory.

Every feature has its own module.

No circular dependencies.

Shared code belongs in core.

Business logic shall not exist inside UI widgets.

Controllers shall remain focused and maintainable.

Source code shall be self-documenting whenever possible.

---

# Success Criteria

The architecture is considered successful if it allows:

Independent feature development.

Easy maintenance.

High security.

Scalable deployment.

Clean testing.

Long-term evolution.

---

# Change Control

This document is governed by the project's Vision Freeze.

Any architectural modification requires:

1. Explicit approval.
2. Version update.
3. Documentation update.