# Operations runbook

## Health
- `GET /health/live`: process liveness.
- `GET /health/ready`: currently returns 503 until canonical identity verification and the event bus consumer are configured.

## Incident handling
1. Disable gateway traffic at the edge if cross-tenant delivery is suspected.
2. Preserve sanitized logs and request/correlation IDs; do not export secrets or customer payment data.
3. Check deployment logs, memory, connection counts, broker connectivity, and event rejection counters.
4. Rotate the internal event token if compromise is suspected.
5. Re-enable traffic only after authorization and tenant-isolation tests pass.

## Rollback
The gateway is independently deployed. Roll back or disable its route without modifying the Python API's payment ingestion or reconciliation workflows.
