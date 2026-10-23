# Phase 1 — Foundation Checklist

Phase 1 targets reproducible development, build configuration, test execution and container build.

- [x] Define a shared `mix check` alias for formatting, warnings-as-errors compilation and tests.
- [x] Configure CI formatting, compilation, tests, release compilation and container build jobs.
- [x] Add production configuration validation for host, secret and allowed origins.
- [x] Run the container as a non-root user and add a container liveness check.
- [x] Add HTTP liveness/readiness regression tests.
- [x] Add local development and configuration documentation.
- [x] Exclude local secrets, build output and dependencies from Docker build context.
- [ ] Generate and commit `mix.lock` from a real `mix deps.get` run.
- [ ] Observe a successful GitHub Actions run.
- [ ] Verify `mix format --check-formatted`, compilation, tests and Docker build in a real Elixir/Docker environment.

**Status:** Source and workflow changes are committed, but Phase 1 is not verified complete until the remaining checks are executed. Do not promote this scaffold to production.
