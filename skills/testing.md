# Testing Skill

## Workflow
1. Identify changed behavior, contracts, risk and acceptance criteria.
2. Inspect existing tests, fixtures, test commands and CI.
3. Add unit tests for deterministic logic and integration tests for real boundaries.
4. Add regression tests for defects and tenant-isolation tests for tenant-aware code.
5. Cover success, invalid input, duplicates, retries, timeouts, concurrency and dependency failure.
6. Run formatter, compiler, static checks, targeted tests and the relevant full suite.
7. Report exact commands and observed results.

## Required security cases
Test expired or invalid tokens, wrong issuer/audience, wrong tenant, privilege escalation, unauthorized channel joins, malformed events and payload leakage.

## Rules
- Never claim a test passed unless it was actually run and observed.
- Never use production credentials or customer data in tests.
- Mocks do not prove a real provider integration works.
- Avoid timing-based flaky tests; prefer deterministic synchronization.
