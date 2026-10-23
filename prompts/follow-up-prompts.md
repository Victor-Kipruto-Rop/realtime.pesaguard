# Follow-up Prompt Library

Use these after the initial phase implementation. Replace bracketed text with actual evidence; never let an agent fill unknown facts by guessing. Follow-ups are reviews and corrections within the same phase unless the prompt explicitly authorizes a transition.

## 1. Universal implementation review
“Review the current phase against `prompts/README.md`, its phase prompt and checklist. Inspect the diff and actual implementation. Identify missing requirements, security regressions, scope drift, unsupported assumptions and misleading documentation. Fix only defects in the current phase, add regression tests, run all available checks, and record exact results. Do not claim an unrun check passed. Do not begin the next phase.”

## 2. Checklist-only audit
“Independently verify every checkbox in [PHASE CHECKLIST]. For each item, cite the file, test output, CI run or deployment evidence that proves it. Mark unsupported items blocked/unverified; do not infer completion from code presence or a written plan. Make only checklist/documentation corrections and list missing evidence.”

## 3. Failing test/build follow-up
“Investigate this actual failure: [PASTE COMMAND AND OUTPUT]. Reproduce it if possible, identify the root cause, and make the smallest in-scope fix. Do not suppress warnings, weaken assertions, skip tests, fabricate dependencies or broaden scope. Rerun the failing command and relevant regression suite; report before/after evidence.”

## 4. Contract discovery blocker
“The required external contract is unknown: [IDENTITY / EVENT PRODUCER / BROKER / API]. Search the repository and connected authoritative sources for evidence. Return exact source locations and verified facts, separate from assumptions. Do not create production configuration from guesses. If the contract remains unavailable, document the blocker and preserve fail-closed behavior.”

## 5. Security challenge
“Review [COMPONENT] as an adversarial security engineer. Attempt to violate tenant isolation, spoof identity, bypass validation, replay events, exhaust resources or leak secrets using safe tests. Add regression tests for reproducible defects, fix only the current phase's issues, and report severity and evidence. Do not run destructive tests against production.”

## 6. Integration follow-up
“Verify [INTEGRATION] against the real producer/provider/broker contract. Check authentication, TLS, timeouts, retries, idempotency, schema compatibility, failure behavior and observability. Use a real test environment where available. Distinguish mocked unit tests from real integration tests. If access or contracts are missing, mark integration blocked rather than simulating success.”

## 7. No-scope-drift recovery
“The last change may have exceeded scope. Compare the diff with the current phase prompt. Revert or isolate unrelated changes without discarding valid existing user work. Preserve security controls and tests. Explain what was removed and verify the focused diff.”

## 8. Pre-commit review
“Review the complete staged diff for secrets, generated files, accidental deletions, unrelated formatting, unsafe defaults, cross-tenant access, inaccurate docs and missing tests. Run applicable format/compile/test checks. Do not commit if a security-critical issue or unexplained failing check remains; report the exact blocker.”

## 9. CI follow-up
“Inspect the actual latest GitHub Actions run for commit [SHA]. Retrieve job and step results/logs. Diagnose failures from real logs, make only in-scope corrections, push/commit if authorized, and inspect the new run. A workflow file existing is not evidence that CI passed.”

## 10. Phase handoff
“Prepare a handoff for Phase [N]: summarize verified implementation, changed files/commit, tests and exact results, known limitations, unresolved blockers, external decisions needed and the next phase's prerequisites. Do not start Phase [N+1]. Mark the phase COMPLETE only if every exit gate has evidence; otherwise mark PARTIAL/BLOCKED.”

## 11. Current Phase 02 contract follow-up
“Inspect the canonical PesaGuard auth implementation and prove the token format, signing algorithm, issuer, audience, claims, expiry and key rotation model from source. Compare it to the current HS256-only adapter. Adapt only after the real contract is established. If the source is unavailable, leave socket auth fail-closed, document the exact missing evidence, and do not declare identity integration complete.”

## 12. Current Phase 01 environment follow-up
“From a clean checkout, run dependency resolution, formatting, warnings-as-errors compilation, tests and Docker build. Inspect the actual CI run and logs. Commit the real generated lockfile and minimal fixes. Do not fabricate a lockfile or report any command as passed unless it ran successfully.”
