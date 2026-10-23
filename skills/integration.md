# Integration Engineering Skill

## Workflow
1. Find authoritative provider docs, contracts and current backend implementation.
2. Confirm endpoint/version, auth, schemas, timeouts, rate limits, idempotency, signatures, retry rules and error semantics.
3. Create an adapter boundary for provider-specific behavior.
4. Validate and normalize inputs/outputs while preserving safe correlation IDs.
5. Define bounded retries, backoff, failure handling and manual recovery.
6. Store secrets in the deployment secret manager and redact them from logs.
7. Test invalid credentials, throttling, malformed responses, downtime and duplicate callbacks.
8. Document sandbox versus production behavior.

## PesaGuard boundaries
PesaGuard consumes supported M-Pesa Daraja C2B/STK callbacks and reconciles them against internal ledger records. It does not initiate or confirm payments, refund, move funds, or execute settlements. Do not claim Airtel, bank, POS, BRS, KRA, IPRS or identity-provider integrations are implemented unless repository evidence confirms it. Represent unavailable integrations as not configured or pending review, never fake success.
