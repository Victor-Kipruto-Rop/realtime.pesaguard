# Phase 01 Prompt — Build Foundation and Reproducible Development

## Mission
Make the existing Elixir/Phoenix scaffold reproducibly buildable, testable and containerizable before adding further runtime behavior.

## Mandatory context
Read `prompts/README.md`, `docs/project-phases.md`, `docs/development.md`, `docs/phase-1-checklist.md`, and skills for implementation, testing, DevOps, CI/CD and code review. Inspect all current config, supervision tree, endpoint, dependencies, tests, Dockerfile and CI.

## Execute
1. Audit the existing project and preserve valid work. Verify compatible Elixir/OTP/dependency versions from actual project configuration.
2. Resolve dependency configuration and generate `mix.lock` using real `mix deps.get` in an Elixir environment. Never fabricate a lockfile.
3. Ensure format, warnings-as-errors compilation, tests and release/container build are available as explicit, reproducible commands.
4. Check supervision, endpoint startup, dev/test/prod configuration, required environment variables, health semantics and safe startup failures.
5. Make Docker build reproducible, use a non-root runtime user, include only required runtime assets, and ensure health checks reflect the intended endpoint.
6. Ensure CI executes format, compile, tests and image build on the intended triggers. Inspect job logs/results where available.
7. Add regression tests and concise local setup instructions. Update the checklist with evidence, not intention.

## Scope lock
Do not implement identity integration, Kafka consumption, tenant subscription access or dashboard features here. Readiness must not pretend downstream integrations are available.

## Acceptance checklist
- [ ] Real dependency resolution completed and lockfile committed.
- [ ] Formatting check, warnings-as-errors compilation and tests pass in a clean environment.
- [ ] Docker image builds successfully.
- [ ] Actual CI run is inspected and its status recorded.
- [ ] Required production configuration is documented without committing secrets.
- [ ] Health/readiness semantics are tested and truthful.
- [ ] Any unavailable command is marked unverified, not passed.

## Required closeout
Update `docs/phase-1-checklist.md` and relevant docs with actual output/status. Do not begin Phase 02 automatically.

## Follow-up prompt
“Re-audit Phase 01 from a clean checkout. Run every available gate, inspect the lockfile and CI logs, fix only foundation issues, and update the checklist with exact command results. If the environment cannot run a gate, mark it blocked and state what is needed; do not claim completion.”
