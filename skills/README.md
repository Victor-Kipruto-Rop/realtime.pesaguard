# AI Agent Skills

Task-oriented playbooks for agents working on PesaGuard Real-Time Gateway.

## Rules for every agent
1. Read the relevant skill before planning or changing code.
2. Inspect repository code and contracts before implementation.
3. Prefer small, tested, reviewable changes.
4. Never invent credentials, provider capabilities, event schemas, tenant identities, or test results.
5. Python remains authoritative for reconciliation, financial decisions, payment ingestion, and business state.
6. Distinguish implemented, scaffolded, planned, blocked, and unverified behavior.
7. Report files changed, checks actually run, failures, assumptions, and remaining production gates.

## Skill index
- testing.md — tests and verification
- integration.md — provider and service integrations
- implementation.md — implementation workflow
- security-hardening.md — application and infrastructure security
- follow-up.md — continuity across tasks and phases
- data-engineering.md — ingestion, quality, lineage, reconciliation data
- software-developer.md — everyday engineering standards
- devops.md — containers, hosting, operations
- system-design.md — service boundaries and architecture decisions
- database-architecture.md — schemas, migrations, tenant isolation
- api-design.md — HTTP and WebSocket contracts
- event-driven-architecture.md — events, retries, consumers
- privacy-compliance.md — sensitive data and obligations
- observability.md — logs, metrics, traces and alerts
- incident-response.md — outage and security response
- performance-scalability.md — capacity and backpressure
- code-review.md — review and defect reporting
- documentation.md — accurate docs and runbooks
- cicd-release.md — automation and releases
- production-readiness.md — go-live checklist

Read the narrowest relevant skill first, then related skills for cross-cutting tasks.
