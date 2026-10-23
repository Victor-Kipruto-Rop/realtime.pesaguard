# Phase 11 Prompt — Staging and Deployment Integration

## Mission
Deploy the gateway as a separate service to staging, with verified configuration, safe network boundaries, smoke tests and rollback.

## Mandatory context
Read universal prompt rules, Dockerfile, `render.yaml`, runtime configuration, CI, runbooks and Render/deployment/security skills. Inspect the actual target environment and available secrets without exposing values.

## Execute
1. Confirm runtime image, startup command, port binding, health endpoints, graceful shutdown, resource settings and environment-specific config.
2. Review the Render Blueprint and any other target configuration against actual service dependencies. Keep production traffic disabled while auth, tenant authorization, event contract or consumer gates remain open.
3. Inventory every required environment variable by owner, source, secret/non-secret classification, rotation process and environment. Never commit secret values.
4. Verify TLS/WSS, allowed origins, private broker/backend connectivity, egress, service authentication and public/private endpoint exposure.
5. Deploy to staging only after applicable phase gates pass. Capture deploy identifiers and actual service logs/health results; do not claim success based on a YAML file.
6. Run smoke tests for startup, liveness, readiness, authentication, authorized tenant delivery, invalid credentials, broker behavior and shutdown as applicable.
7. Document rollback steps, configuration rollback, secret rotation, data/offset considerations and who can execute rollback.

## Scope lock
Do not turn on real customer traffic, alter Python production processing, duplicate M-Pesa consumers or expose internal services publicly. Preserve the existing production source of truth.

## Acceptance checklist
- [ ] Image and platform configuration are reviewed and tested.
- [ ] Secrets are provisioned safely and not present in Git/client assets.
- [ ] Network, TLS and origin policies are verified.
- [ ] Staging deployment has real evidence and smoke tests pass.
- [ ] Readiness reflects real dependencies.
- [ ] Rollback is documented and feasible.
- [ ] No production traffic is enabled while a prior hard gate is open.

## Required closeout
Record deployment ID, environment, test evidence and rollback owner in Phase 11 checklist. Do not promote automatically to Phase 12.

## Follow-up prompt
“Review the staging deployment against its configuration and logs. Verify secret handling, TLS/origins, dependency connectivity, health/readiness and rollback; rerun smoke tests and fix only deployment defects. Keep production traffic disabled until explicitly approved.”
