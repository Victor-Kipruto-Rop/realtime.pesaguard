# Database Architecture Skill

- Define entities, ownership, lifecycle, constraints, relationships and deletion policy.
- Use keys, foreign keys, unique/check constraints and indexes for real invariants.
- Enforce tenant scope on every access path; test any PostgreSQL row-level security configuration.
- Use reviewed migrations with forward and rollback considerations.
- Use transactions for atomic changes and appropriate isolation for concurrency.
- Avoid N+1 queries, unbounded scans and unbounded result sets.
- Define retention, backups, restore tests, encryption and access controls.
- Review query plans and index write costs with safe representative data.
- Keep secrets and sensitive payloads out of database logs.

Use exact numeric/decimal types or integer minor units according to the established contract. Record currency explicitly. Preserve historical financial evidence with an audit trail.
