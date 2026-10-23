# Authentication integration contract

The gateway must use the same canonical identity issuer as PesaGuard's app/API. The precise issuer, audience, token format, JWKS location, claim names, and refresh behavior must be confirmed from the real backend configuration before implementation.

Required checks:
- Cryptographic signature and allowed algorithm
- Exact issuer and audience
- Expiration and not-before timestamps
- Tenant membership and role/permission claims
- Revocation/session policy where supported
- Rate-limited connection attempts

The current socket connect handler denies all connections. Do not weaken this default to make the dashboard connect. Never trust a tenant identifier from a client parameter as proof of membership.
