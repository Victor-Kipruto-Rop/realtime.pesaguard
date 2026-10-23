# PesaGuard Real-Time Gateway — Phase Prompt Pack

These prompts are the execution contract for AI coding agents working in this repository. Run one phase at a time, in numerical order, and preserve each phase's exit gate. Do not paste several phase prompts into one unconstrained task.

## Mandatory operating rules

1. **Read before acting.** Read this file, `AGENTS.md` if present, `docs/project-phases.md`, the current phase prompt, relevant `skills/*.md`, and the actual files/tests/configuration involved. If a referenced file does not exist, report that and continue only when safe.
2. **Audit before editing.** Inspect Git status, branch, recent commits, project tree, dependency versions, existing implementations, test commands, CI, and contracts. Do not overwrite functioning work based on assumptions.
3. **One phase, one scope.** Work only on the requested phase and its direct prerequisites. Do not silently start future phases, redesign unrelated components, rename projects, change frameworks, or expand product scope. If a blocker belongs to another phase, record it and stop at the boundary.
4. **No AI scope drift.** Do not invent features, schemas, environment variables, providers, broker topics, issuer claims, API responses, credentials, business data, metrics, or test results. Derive contracts from repository evidence or an explicitly identified authoritative source. Label unresolved items as blocked/unverified and ask one focused question when a decision is essential.
5. **PesaGuard boundary.** The Python backend remains authoritative for M-Pesa ingestion, reconciliation, risk decisions and financial state. This Elixir/Phoenix gateway transports approved events only. It must never initiate, confirm, refund, move or settle payments, or invent transaction outcomes.
6. **Tenant isolation is mandatory.** Never trust a client-provided tenant ID as proof of access. Fail closed when identity, membership, configuration or required dependencies cannot be verified. Never weaken authorization to make a demo pass.
7. **No fake completion.** Creating files or configuring CI is not proof of successful compilation, tests, deployment or integration. Report exactly which commands ran, their actual outputs/status, and what could not be run. Never fabricate green checks.
8. **Small, reviewable changes.** Prefer the smallest complete implementation that satisfies the phase. Avoid speculative abstractions, duplicate code, placeholder implementations presented as working, unnecessary dependencies and broad formatting churn.
9. **Tests and documentation travel with code.** Add or update tests for every changed behavior and update documentation to describe what actually exists. Do not delete or weaken tests just to obtain a pass.
10. **Secrets and privacy.** Never commit real secrets or print tokens, personal data, financial identifiers or sensitive payloads. Use redacted examples and environment placeholders.
11. **Dependencies and external systems.** Verify the actual issuer, API, event producer, broker, deployment platform and schema before integrating. If access is unavailable, implement only a safe adapter boundary and clearly mark the integration blocked. Do not configure an assumed contract as production truth.
12. **Definition of done.** The phase is complete only when all exit criteria are evidenced, tests and CI are actually verified where available, documentation and checklist are updated, unresolved risks are stated, and a commit/PR can be identified. Otherwise mark it **PARTIAL / BLOCKED**, not complete.

## Required agent workflow

- **Step A — Baseline:** State branch/commit, working-tree state, runtime availability, current implementation status, and the relevant contracts/files.
- **Step B — Plan:** List the exact changes, tests, risks and dependencies. Keep the plan within the selected phase.
- **Step C — Implement:** Make the smallest coherent change; preserve public contracts unless a justified, documented migration is necessary.
- **Step D — Verify:** Run relevant format, compile, unit, integration, security and container checks that the environment supports. Record command-by-command results. Do not imply an unrun command passed.
- **Step E — Review:** Inspect the diff for accidental changes, secret exposure, cross-tenant paths, TODOs masquerading as features, dependency drift and misleading docs.
- **Step F — Close:** Update the phase checklist and status docs; report changed files, evidence, failures, assumptions, blocked items and next permitted phase.

## Universal completion checklist

- [ ] Correct phase prompt and relevant skills were read.
- [ ] Existing implementation and contracts were inspected before editing.
- [ ] Scope remained within this phase.
- [ ] No invented integration behavior, test evidence, secrets or financial outcomes.
- [ ] Tests cover success, invalid input, failure and security boundaries relevant to the change.
- [ ] Commands actually run are listed with truthful results.
- [ ] Documentation and the phase checklist match the code.
- [ ] Diff reviewed; no unrelated or unsafe changes.
- [ ] Remaining blockers and risks are explicit.
- [ ] Exit gate evidence is recorded; phase status is accurate.

## Phase index

- [Phase 00 — Scope, inventory and agent workflow](phase-00-scope-and-inventory.md)
- [Phase 01 — Reproducible foundation](phase-01-foundation.md)
- [Phase 02 — Authentication and identity](phase-02-authentication.md)
- [Phase 03 — Tenant authorization and channel security](phase-03-tenant-authorization.md)
- [Phase 04 — Event contracts and validation](phase-04-event-contracts.md)
- [Phase 05 — Event transport and consumer reliability](phase-05-event-transport.md)
- [Phase 06 — Real-time routing and delivery](phase-06-routing-delivery.md)
- [Phase 07 — Dashboard client integration](phase-07-dashboard-client.md)
- [Phase 08 — Internal API and abuse controls](phase-08-internal-api-hardening.md)
- [Phase 09 — Observability and reliability](phase-09-observability.md)
- [Phase 10 — Security, privacy and resilience tests](phase-10-security-resilience.md)
- [Phase 11 — Staging and deployment](phase-11-deployment.md)
- [Phase 12 — Production rollout and operations](phase-12-production-rollout.md)
- [Follow-up prompts and handoff templates](follow-up-prompts.md)

Start with Phase 00 to establish an evidence-based baseline. If a phase has already been partially implemented, audit and finish/verify the existing work rather than rebuilding it from scratch.
