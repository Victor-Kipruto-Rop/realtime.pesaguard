# Phase 00 Prompt — Scope, Inventory and Agent Workflow

## Mission
Establish an evidence-based baseline for the PesaGuard Real-Time Gateway and make coding-agent behavior repeatable. This phase is repository discovery and workflow control; do not implement future business functionality.

## Mandatory context
Read `prompts/README.md`, `docs/project-phases.md`, `README.md`, `skills/README.md`, and the relevant implementation/security/testing/integration/architecture skills. Inspect the actual repository, not just documentation.

## Execute
1. Record current branch, commit, Git status, repository tree, language/runtime versions, dependencies, CI workflows, Docker/Render configuration and available test commands.
2. Inspect every major boundary: Phoenix endpoint/socket/channel, token verifier, tenant policy, event envelope, internal event endpoint, messaging consumer, router/broadcaster, client assets, health endpoints and config.
3. Identify the canonical Python backend and find evidence for identity claims, internal service authentication, event producer, topic names, schemas and delivery semantics. Use repository evidence or an authoritative source; do not infer missing contracts.
4. Create or update root `AGENTS.md` with mandatory scope, security, testing and truthful-reporting rules. Make relevant skills discoverable and tell agents when to read them.
5. Create/update a status inventory marking each subsystem **implemented**, **scaffold-only**, **blocked**, or **unverified**. Add architecture decision records only for decisions supported by evidence; unresolved choices must remain open questions.
6. Record baseline command results. If Elixir, Docker, credentials, broker, or backend source is unavailable, state the limitation and do not claim validation.

## Scope lock
Do not change event formats, auth protocol, tenant behavior, dependencies, hosting topology or dashboard implementation in this phase unless a minimal change is required to document the workflow and is safe.

## Acceptance checklist
- [ ] Root agent instructions and skill-loading convention are committed.
- [ ] Status inventory distinguishes actual implementation from scaffolding.
- [ ] Identity, broker, event and deployment assumptions are recorded with evidence or marked unresolved.
- [ ] Baseline test/CI status is accurate.
- [ ] No future phase is falsely marked complete.

## Required closeout
Update the Phase 00 checklist/status. List evidence sources, missing contracts and blockers. Do not proceed automatically to Phase 01.

## Follow-up prompt
“Review Phase 00 against its checklist. Inspect the diff and repository state, verify each claim against actual files or command output, fix only Phase 00 omissions, and report remaining unknowns. Do not begin Phase 01 until I explicitly ask.”
