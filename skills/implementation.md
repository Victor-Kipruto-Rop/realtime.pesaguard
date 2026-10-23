# Implementation Skill

1. Restate acceptance criteria and inspect the repository before editing.
2. Trace the flow from route/UI through domain logic, persistence and external dependencies.
3. Identify compatibility, migration, security, tenant and rollout risks.
4. Plan affected files and tests.
5. Implement the smallest coherent vertical slice.
6. Add validation, explicit errors, structured logging and tests.
7. Run formatter, compiler, static analysis and relevant tests.
8. Review the diff for secrets, accidental data exposure, unfinished stubs and unrelated changes.
9. Report what works, what remains and which assumptions are unverified.

Reuse existing conventions and dependencies where reasonable. Do not replace the Python core with Phoenix. Do not fabricate production records or provider responses. Do not make a stub look like a working feature. Include rollback notes for risky schema or deployment changes.
