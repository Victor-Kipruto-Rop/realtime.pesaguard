# Phase 09 Prompt — Observability and Operational Reliability

## Mission
Make real service behavior diagnosable without leaking sensitive data or creating unbounded telemetry cost.

## Mandatory context
Read universal prompt rules, current logging/metrics/tracing setup, deployment config and skills for observability, incident response, performance and privacy.

## Execute
1. Inventory existing telemetry libraries, exporter destinations, metric definitions, log format, tracing propagation and platform integration. Verify the configured destination exists before claiming data is delivered.
2. Add structured logs with request/event/correlation identifiers where available; redact authorization headers, tokens, sensitive payloads and personal/financial identifiers.
3. Instrument HTTP latency/errors, active connections, auth rejection, event validation rejection, consumer lag, retries, dead letters, publish failures and dependency state where those components actually exist.
4. Keep metric labels low-cardinality. Never use tenant IDs, transaction IDs, phone numbers, event IDs or other per-record values as metric labels.
5. Propagate trace/correlation context across the gateway and producer only where the real producer supports it.
6. Add alerts and actionable runbooks for broker outage/lag, identity outage, elevated rejection, connection failures and resource saturation. Test alert routing where possible.
7. Define SLOs only from explicit user/business requirements or measured baseline; do not invent targets or imply measurement that has not occurred.

## Scope lock
Do not add telemetry for nonexistent integrations or label synthetic measurements as production. Do not log raw event payloads to improve debugging.

## Acceptance checklist
- [ ] Telemetry destination and delivery are verified.
- [ ] Logs are structured, useful and redacted.
- [ ] Required metrics exist with bounded cardinality.
- [ ] Tracing propagation is evidence-based.
- [ ] Alerts and runbooks are actionable and tested or explicitly unverified.
- [ ] SLOs have a stated source and measurement method.
- [ ] No secrets or sensitive IDs leak into logs/metrics.

## Required closeout
Update dashboards/runbooks and Phase 09 checklist with actual evidence. Do not proceed to load/security sign-off without telemetry verification.

## Follow-up prompt
“Run a telemetry privacy and usefulness review. Verify metrics/logs reach their real destination, inspect label cardinality and redaction, test alert paths, and fix only observability gaps supported by evidence.”
