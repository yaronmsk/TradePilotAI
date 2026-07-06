# TradePilot AI

Document ID:
TP-011

Document:
Engineering Decisions Register

Version:
1.0

Status:
Approved

Last Updated:
2026-07-06

Owner:
TradePilot AI

Related Documents:
- TP-001 Master Specification
- TP-005 Architecture Specification
- TP-006 Development Guidelines

---

# Purpose

This document records the significant engineering, architectural, product, and development decisions made during the TradePilot AI project.

The objective is to preserve the reasoning behind important decisions so they remain understandable throughout the project's lifetime.

This document records **why** decisions were made, not only **what** was decided.

---

# Decision Format

Every decision shall include:

- Decision ID
- Status
- Date
- Decision
- Rationale
- Impact

Status values:

- Proposed
- Accepted
- Deprecated
- Superseded

---

# ADR-001

Status

Accepted

Date

2026-07-06

Decision

TradePilot AI shall follow a feature-based Flutter architecture.

Rationale

Feature-based architecture provides better scalability, ownership, maintainability, and separation of concerns than organizing code by technical layers alone.

Impact

All Flutter development follows the feature-based structure defined in the Architecture Specification.

---

# ADR-002

Status

Accepted

Date

2026-07-06

Decision

The application shall never claim to predict future market prices.

Rationale

Financial markets cannot be predicted with certainty.

TradePilot AI is designed as an evidence-based decision support platform rather than a prediction engine.

Impact

All recommendations, documentation, user interface, and marketing material shall use language consistent with this principle.

---

# ADR-003

Status

Accepted

Date

2026-07-06

Decision

TradePilot AI shall provide explainable recommendations.

Rationale

Users should understand why a recommendation exists rather than blindly trusting AI output.

Transparency increases trust and supports informed decision-making.

Impact

Every recommendation must include supporting evidence and an explanation.

---

# ADR-004

Status

Accepted

Date

2026-07-06

Decision

The recommendation system shall contain two independent analytical approaches.

Rationale

Users may prefer historical evidence, current statistical analysis, or both.

Independent engines improve transparency and allow users to compare different perspectives.

Impact

The AI architecture shall support:

- Historical Evidence Engine
- Current Statistical Analysis Engine
- Combined Recommendation Mode

---

# ADR-005

Status

Accepted

Date

2026-07-06

Decision

Historical evidence shall be emphasized over a standalone confidence percentage.

Rationale

Historical comparisons provide more meaningful context than presenting a single confidence number.

Impact

The UI should prioritize:

- Historical comparisons
- Similar situations
- Historical outcomes

Confidence percentages may be displayed only as supplementary information.

---

# ADR-006

Status

Accepted

Date

2026-07-06

Decision

The application shall use a professional silver design language.

Rationale

The target audience consists of investors who value clarity and professionalism over decorative interfaces.

Impact

The UI follows the principles defined in the UI/UX Specification.

---

# ADR-007

Status

Accepted

Date

2026-07-06

Decision

The project follows a Vision Freeze during MVP development.

Rationale

Restricting new features during implementation reduces scope creep and increases the likelihood of completing the MVP.

Impact

Only approved functionality may be implemented.

Future ideas shall be documented separately and evaluated after the MVP.

---

# ADR-008

Status

Accepted

Date

2026-07-06

Decision

Security shall be considered a core architectural requirement.

Rationale

Security cannot be effectively added after the system has been built.

Impact

Every implementation must comply with the Security Specification.

---

# ADR-009

Status

Accepted

Date

2026-07-06

Decision

Project documentation shall be maintained alongside the source code.

Rationale

Documentation and implementation should evolve together to avoid inconsistencies.

Impact

Documentation updates are considered part of the Definition of Done.

---

# ADR-010

Status

Accepted

Date

2026-07-06

Decision

Development shall occur on the develop branch.

The main branch shall remain stable.

Rationale

Separating stable releases from ongoing development reduces risk and improves release quality.

Impact

Daily work occurs on the develop branch.

Completed milestones are merged into main.

---

# Future Decisions

Future architectural and product decisions shall be appended to this document using the same format.

Existing accepted decisions should not be modified unless they are formally superseded.

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