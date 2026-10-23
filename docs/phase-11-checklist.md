# Phase 11 — Staging and deployment

**Status: BLOCKED — no verified gateway service or staging end-to-end deployment.**

## Exit gates
- [ ] Pass Phase 1–10 required checks and obtain a generated, committed `mix.lock`.
- [ ] Verify the Render Blueprint, runtime environment, origin list, canonical auth URL and secret inventory.
- [ ] Verify private network/service-auth design for internal event publishers.
- [ ] Deploy to staging without customer traffic and run readiness, auth, event contract and cross-tenant smoke tests.
- [ ] Verify graceful shutdown, TLS, secret rotation, logs and rollback.
- [ ] Record deployment ID, test outputs and actual service status.

Do not create/promote a production gateway service while build and release checks are failing or unobservable.
