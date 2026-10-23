# Phase 3 — Tenant authorization checklist

**Status: IMPLEMENTATION COMMITTED TO FEATURE BRANCH; VERIFICATION PENDING.**
This status is not a release approval. No compile/test/CI result is implied.

## Implemented in this branch

- [x] Socket authentication assigns the canonical backend response to `socket.assigns.verified_claims` (existing Phase 2 integration).
- [x] The tenant channel accepts only the exact `tenant:<tenant_id>:transactions` topic shape.
- [x] Requested tenant must exactly match the backend-validated `tenant_id`.
- [x] The validated permission list must be a list of strings containing `read:transactions`.
- [x] Missing/malformed claims, malformed tenant IDs, unsupported topics, and tenant mismatches fail closed.
- [x] Client join params do not override the validated identity.
- [x] Denial logs include only a reason, not tokens, user/tenant IDs, claims, params, or payloads.
- [x] Regression tests cover allowed access, forged join params, cross-tenant access, missing identity/tenant, missing and malformed permissions, unsupported topics, and malformed tenant IDs.
- [x] No event broadcasting or event-contract behavior was added in Phase 3.

## Verification still required

- [ ] Run `mix format --check-formatted`.
- [ ] Run `mix compile --warnings-as-errors`.
- [ ] Run `mix test` and confirm the configured coverage threshold.
- [ ] Confirm GitHub Actions has a successful run for the final branch commit.
- [ ] Verify the production `PESAGUARD_ALLOWED_ORIGINS` value and actual endpoint origin enforcement.
- [ ] Add/verify connection and join rate limits.
- [ ] Agree and implement a bounded strategy for disconnect/revalidation after token expiry, logout, session revocation, membership changes, or permission changes.
- [ ] Perform a security review of all channel declarations and all paths that select tenant topics.
- [ ] Confirm whether tenant IDs in the canonical API contract always satisfy the gateway's documented identifier format.

## Security model and limitations

The current canonical `GET /auth/verify` contract returns the authenticated user's current `tenant_id`, roles, and permissions. It does not provide a complete organization-membership lookup contract. This implementation therefore authorizes only the single tenant explicitly present in the verified response; it does not add cross-tenant membership support or infer access from a role name.

The only supported subscription is transaction read access. Other resource topics must not be enabled until their permissions and event contracts are agreed and tested. The gateway remains a transport layer and must not initiate, confirm, refund, move, or settle payments.

## Release gate

Keep production dashboard traffic off this gateway until Phase 2 and Phase 3 verification evidence is recorded, origin/abuse controls are confirmed, and the long-lived socket revocation limitation is addressed or explicitly accepted by the security owner.
