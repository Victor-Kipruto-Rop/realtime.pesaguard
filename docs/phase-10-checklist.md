# Phase 10 — Security, privacy and resilience testing

**Status: NOT VERIFIED — blocked by unavailable CI execution and missing broker/staging path.**

## Exit gates
- [ ] Complete a threat model covering canonical identity, tenant membership, internal publishers, broker, sockets, secrets, logs and deployment.
- [ ] Pass tenant-isolation and auth regression tests in a working Elixir/OTP environment.
- [ ] Run dependency vulnerability checks and review high/critical findings.
- [ ] Test auth and broker outages, duplicates, malformed events, restart, slow clients and reconnect storms in a controlled environment.
- [ ] Run load tests with recorded environment, duration, concurrency, event rate, latency percentiles, errors and resource use.
- [ ] Document privacy minimization, retention, incident handling and credential rotation.
- [ ] Fix critical/high findings or record authorized risk acceptance and mitigation.

No security certification, measured capacity, or successful resilience test is claimed.
