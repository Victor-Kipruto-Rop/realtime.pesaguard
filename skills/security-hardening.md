# Security Hardening Skill

- Verify tokens cryptographically and validate issuer, audience, expiry, not-before, algorithm and required claims.
- Authorize every resource and channel from trusted claims and server-side membership.
- Never trust client-supplied tenant IDs as proof of access.
- Use least privilege, deny-by-default behavior, short-lived credentials and rotation.
- Validate schemas, content types, sizes, file types and event types.
- Apply rate limits, timeouts, origin checks, safe CORS and appropriate CSRF protections.
- Prevent injection, SSRF, path traversal, mass assignment and unsafe deserialization.
- Redact tokens, PINs, account identifiers, phone numbers, statements, documents and sensitive payloads.
- Keep secrets out of Git and browser bundles.
- Use TLS, secure headers, dependency scanning and least-privilege service identities.
- Add negative tests for cross-tenant access and privilege escalation.

If tenant leakage or credential compromise is suspected, recommend containment, evidence preservation, credential rotation and isolation tests before re-enabling traffic.
