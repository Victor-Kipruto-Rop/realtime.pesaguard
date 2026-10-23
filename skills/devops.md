# DevOps Skill

1. Inspect hosting, runtime, container, environment and health-check configuration.
2. Separate local, CI, staging and production settings.
3. Build reproducible artifacts and manage runtime versions intentionally.
4. Use minimal containers, correct signal handling and non-root execution where feasible.
5. Store secrets in secret managers, not repository files.
6. Separate liveness from readiness; readiness must reflect required dependencies.
7. Add logs, metrics, traces, alerts, runbooks and rollback steps.
8. Verify deployments using actual service status, logs and smoke tests.

Keep the Phoenix gateway separate from the Python backend. Do not route production traffic before authentication and event transport are ready. Report deployment state only after checking it.
