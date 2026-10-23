# Phase 2 checklist — Authentication and identity

## Implemented in repository
- [x] Added a fail-closed HS256 JWT verification adapter using Joken.
- [x] Validate signature, configured issuer/audience, expiration and optional not-before.
- [x] Require non-empty `sub` and `tenant_id` claims and return an allow-listed set of verified claims.
- [x] Authenticate Phoenix socket connection attempts and assign only verified claims.
- [x] Keep tenant channel joins denied until Phase 3 membership authorization is implemented.
- [x] Add environment placeholders and documentation for explicit verifier configuration.
- [x] Add unit tests for valid tokens, malformed tokens, wrong signing secret, missing configuration, missing tenant identity, expired tokens and future not-before.
- [x] Document browser token handling risks and the need to verify the canonical issuer contract.

## Blocking items — phase not complete
- [ ] Inspect the real PesaGuard identity provider/API and confirm token format, signing algorithm, issuer, audience, key rotation/JWKS model, exact claims, tenant membership semantics, lifetime and revocation behavior.
- [ ] Adapt the verifier to the confirmed issuer. The current adapter is HS256-only and must not be configured unless that matches the real issuer.
- [ ] Add issuer-generated test tokens or contract tests. Local test-signer tests alone do not prove interoperability.
- [ ] Run `mix format --check-formatted`, `mix compile --warnings-as-errors` and `mix test` in a real Elixir environment.
- [ ] Confirm the actual GitHub Actions run is green.
- [ ] Review token leakage risks in the frontend and reverse-proxy access logs; implement one-time WebSocket tickets if required.
- [ ] Complete Phase 3 authorization before allowing tenant channel joins.

## Security state
- Socket connections now fail closed unless the configured HS256 verifier accepts the token.
- Tenant channel joins are deliberately denied even for authenticated users until authoritative membership authorization exists.
- Readiness must remain unavailable while the event-bus consumer is unimplemented.
- Do not send production traffic through this gateway yet.
