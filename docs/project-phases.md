# PesaGuard Real-Time Gateway — Project Phases

## Mandatory execution prompts

Before implementing any phase, follow [`prompts/README.md`](../prompts/README.md) and the matching `prompts/phase-NN-*.md` file. Each phase prompt contains scope locks, deliverables, acceptance checklists and a follow-up review prompt. Use [`prompts/follow-up-prompts.md`](../prompts/follow-up-prompts.md) for evidence-based verification and handoff. Do not treat a phase as complete without its exit-gate evidence.

## Mission and boundaries

Build a separately deployable Elixir/Phoenix service for secure, low-latency delivery of PesaGuard events to authorized dashboard clients. The existing Python backend remains authoritative for M-Pesa ingestion, reconciliation, risk decisions, and financial records. PostgreSQL remains the authoritative store for persisted business state. Kafka/Redpanda is an event transport only after its real contracts and configuration are verified.

The gateway must not initiate, confirm, refund, move, or settle payments. It must not fabricate events, customer data, provider results, or health status. Every phase is incomplete until its exit criteria are supported by evidence.

## Phase 0 — Scope, inventory, and agent workflow

**Goals**
- Establish an accurate baseline of the repository, runtime, dependencies, CI, hosting, current stubs, and existing Python-backend event contracts.
- Make the repository skills discoverable and actionable for coding agents.

**Deliverables**
- Root `AGENTS.md` with mandatory instructions to read relevant `skills/*.md`.
- Skills index plus implementation workflow, task planning, and completion-verification skills.
- A status inventory that labels every component implemented, scaffold-only, blocked, or unverified.
- Architecture decision records for service boundaries, event transport, identity trust, and deployment.

**Exit gate**
- No assumed provider/broker contract is treated as fact.
- Agent instructions and phase gates are committed.
- Baseline compile/test/CI state is recorded, or explicitly marked unverified.

## Phase 1 — Build foundation and reproducible development

**Goals**
- Make the current scaffold buildable and predictable before adding business functionality.

**Deliverables**
- Valid dependency configuration and committed `mix.lock`.
- Formatting, compilation, unit-test and static-analysis commands.
- Correct Phoenix endpoint/application supervision and environment-specific configuration.
- Reproducible Docker development workflow and documented local setup.
- CI that fails on formatting, compilation or test errors.

**Exit gate**
- `mix deps.get`, `mix format --check-formatted`, `mix compile --warnings-as-errors` where practical, and `mix test` run successfully in a clean environment.
- Docker image builds successfully.
- Actual CI result is observed; no claims based on configuration alone.

## Phase 2 — Authentication and identity integration

**Goals**
- Authenticate dashboard WebSocket connections and internal service requests using the canonical PesaGuard identity contract.

**Deliverables**
- Verified token validation adapter with documented issuer, audience, signature algorithm, expiry, not-before and required claims.
- Secure key/JWKS retrieval and cache/rotation behavior if supported by the actual issuer.
- Separate authentication for internal event publishers.
- Token expiry/revocation behavior appropriate to the agreed identity contract.
- Explicit configuration errors when identity integration is missing.

**Exit gate**
- Valid, expired, malformed, wrong-issuer, wrong-audience, wrong-signature and missing-claim tests pass.
- No hard-coded signing secrets or permissive development bypass can be enabled in production.
- Browser connections remain denied until real verification is configured.

## Phase 3 — Tenant authorization and channel security

**Goals**
- Guarantee that users can subscribe only to events for organizations they are authorized to access.

**Deliverables**
- Trusted tenant and membership claims or server-side membership lookup, based on the real identity contract.
- Per-channel authorization and exact resource/action checks.
- Tenant-scoped topics derived server-side, never from untrusted client input.
- Origin policy, connection limits, join rate limits and safe disconnect behavior.
- Audit events for denied or suspicious access without logging secrets.

**Exit gate**
- Cross-tenant subscription, forged tenant IDs, missing membership, privilege escalation and unauthenticated join tests pass.
- Default-deny behavior is preserved when identity or membership services are unavailable.
- Security review finds no known cross-tenant path in the implemented flows.

## Phase 4 — Event contracts and validation

**Goals**
- Establish a versioned, allow-listed event contract between the Python backend and gateway.

**Deliverables**
- Contract definitions for event envelope, schema version, event ID, event type, trusted tenant scope, occurrence timestamp, correlation/trace IDs and payload.
- Per-event schemas for only verified use cases.
- Payload size limits, strict type and timestamp validation, unknown-event behavior and compatibility policy.
- Contract examples and producer/consumer compatibility tests.
- Sanitization and field allow-lists for client delivery.

**Exit gate**
- Contract is agreed with the Python backend and stored in version control.
- Invalid, oversized, unknown-version and unauthorized-tenant events are rejected safely.
- No arbitrary internal database row or unfiltered sensitive payload is broadcast.

## Phase 5 — Event transport and consumer reliability

**Goals**
- Receive real events from the selected Kafka/Redpanda transport and process them safely.

**Deliverables**
- Broker/topic configuration confirmed from the deployed environment and producer implementation.
- Supervised consumer with explicit acknowledgement behavior.
- Idempotency/deduplication strategy, bounded retries and backoff, poison-message handling and dead-letter/replay procedure.
- Consumer lag, retry, rejection and publish-failure metrics.
- Graceful shutdown and restart recovery.

**Exit gate**
- Integration tests use a real test broker or an explicitly documented compatible test environment.
- Duplicate, malformed, out-of-order, unavailable-broker and restart scenarios are tested.
- No event-loss guarantee is claimed beyond the actual broker and acknowledgement semantics.

## Phase 6 — Real-time event routing and delivery

**Goals**
- Route validated events to the correct authorized tenant channels.

**Deliverables**
- Event router mapping allow-listed event types to authorized delivery topics.
- Phoenix PubSub/Channels integration and stable client event envelopes.
- Connection lifecycle, heartbeat, reconnect and resubscribe guidance.
- Backpressure and slow-client behavior with bounded memory/resource use.
- No delivery to disconnected or unauthorized clients beyond documented guarantees.

**Exit gate**
- Tests prove correct tenant delivery, no cross-tenant delivery, and correct handling of duplicate and unsupported events.
- A test client can receive a verified event end-to-end from producer to channel.
- Delivery is not described as durable client receipt unless acknowledgements and persistence explicitly provide it.

## Phase 7 — Dashboard client integration

**Goals**
- Connect the PesaGuard dashboard to the gateway without making the UI a source of financial truth.

**Deliverables**
- Maintained JavaScript client wrapper with authenticated connection setup.
- Typed event handlers for agreed dashboard use cases such as reconciliation status, risk alerts and data-source health.
- Reconnection with bounded exponential backoff and jitter, stale-connection indicators, and duplicate-event handling.
- UI refresh/fallback path using the authoritative API after reconnect or missed events.
- Safe handling of token renewal and logout.

**Exit gate**
- End-to-end tests demonstrate connection, authorization, event rendering, disconnect/reconnect, logout and expired credentials.
- Dashboard state can be recovered from the authoritative API; WebSocket delivery is not the only record of a financial result.

## Phase 8 — Internal API, operational endpoints, and abuse controls

**Goals**
- Harden internal event-ingestion endpoints and public operational surfaces.

**Deliverables**
- Internal bearer/service-token verification or stronger signed service authentication if the backend contract supports it.
- Trusted service context for tenant scope; the caller must not freely choose tenant scope.
- Request schema and body-size limits, rate limiting, replay/idempotency controls and safe error responses.
- Correct liveness and readiness semantics with dependency-specific diagnostics kept private.
- CORS/origin restrictions and secure HTTP headers where applicable.

**Exit gate**
- Unauthorized, replayed, oversized and malformed requests are rejected.
- Readiness accurately reports required dependencies; liveness remains independent of downstream dependencies.
- No secrets or internal topology leak from error responses.

## Phase 9 — Observability and operational reliability

**Goals**
- Make service health and event flow diagnosable in production.

**Deliverables**
- Structured logs with request/event/correlation IDs and sensitive-field redaction.
- Metrics for HTTP latency/errors, active connections, rejected events, consumer lag, retries, queue depth and dependency state.
- Tracing across the gateway and producer where compatible.
- Actionable alerts and runbooks for broker outage, auth outage, elevated rejection, lag and connection failures.
- Bounded metric cardinality and resource limits.

**Exit gate**
- Telemetry is verified in the configured destination.
- Alerts are tested or otherwise demonstrably wired to the intended receiver.
- No tenant IDs, transaction IDs, tokens or personal data are exposed as metric labels.

## Phase 10 — Security, privacy, and resilience testing

**Goals**
- Validate behavior under adversarial input, dependency failure and load.

**Deliverables**
- Security regression suite, dependency vulnerability checks and threat-model review.
- Tenant-isolation tests covering HTTP, channel join, event routing and logs.
- Load tests for connection counts, burst delivery, slow consumers, reconnect storms and tenant fairness.
- Failure-injection tests for broker, identity provider and downstream dependency outages.
- Data minimization, retention and incident-response guidance.

**Exit gate**
- Critical/high findings are resolved or formally accepted with owner and mitigation.
- Load targets and test conditions are documented from measured results.
- Recovery and failure behavior are demonstrated, not merely described.

## Phase 11 — Deployment and environment integration

**Goals**
- Deploy the gateway safely as a separate service.

**Deliverables**
- Reviewed Render Blueprint and Docker image configuration.
- Environment-specific secret/configuration inventory and rotation procedure.
- TLS, allowed origins, service authentication and private networking decisions verified.
- Staging deployment, smoke tests, rollback procedure and operational ownership.
- Dependency readiness and graceful shutdown verified in the target platform.

**Exit gate**
- Staging passes smoke, security and integration tests.
- No production secret is stored in Git or client assets.
- Production promotion is explicit and rollback is feasible.
- Do not enable production traffic while authentication or event transport remains a stub.

## Phase 12 — Production rollout and ongoing operations

**Goals**
- Release gradually, monitor impact and maintain the service.

**Deliverables**
- Controlled rollout plan with traffic/tenant scope, success metrics and rollback thresholds.
- Post-deploy verification checklist.
- On-call/runbook ownership, incident process and routine dependency updates.
- Capacity review, restore/recovery drills where applicable, and backlog for follow-up improvements.

**Exit gate**
- Production status is verified from actual service state, logs and end-to-end events.
- No unresolved critical security or correctness issue remains.
- Service ownership and ongoing maintenance responsibilities are documented.

## Cross-phase definition of done

A phase is complete only when:
- Deliverables exist in the repository and match actual behavior.
- Relevant automated tests have been run and results recorded.
- Security and tenant-isolation implications have been reviewed.
- Documentation describes the real implementation, not intended behavior.
- Known limitations and blocked dependencies are explicit.
- A commit or pull request is identifiable and reviewed.

## Suggested execution order

0. Scope and agent workflow
1. Build foundation
2. Authentication
3. Tenant authorization
4. Event contracts
5. Event transport
6. Event routing
7. Dashboard client
8. Internal API and abuse controls
9. Observability
10. Security and resilience verification
11. Staging deployment
12. Controlled production rollout

Some design and test work may run in parallel, but phases 2–6 are production traffic gates. Do not route real customer traffic before those gates pass.
