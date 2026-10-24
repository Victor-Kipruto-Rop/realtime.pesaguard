# Phase 9 — Observability and operational reliability

**Status: PARTIAL / UNVERIFIED.**

## Exit gates
- [ ] Inventory existing telemetry, logger metadata and metrics implementation against the gateway's actual event path.
- [ ] Add structured, redacted logs with request/event/correlation IDs without logging tokens, tenant IDs, personal data or raw financial payloads.
- [ ] Measure HTTP latency/errors, active sockets, rejected events, consumer lag, retries, queue depth and publish failures with bounded label cardinality.
- [ ] Verify telemetry reaches the configured real destination.
- [ ] Wire and test actionable alerts for auth outage, broker outage, lag, rejection spikes and connection saturation.
- [ ] Record measured SLO baselines and runbooks; do not invent capacity claims.

No telemetry delivery or alert firing is claimed as verified by repository configuration alone.
