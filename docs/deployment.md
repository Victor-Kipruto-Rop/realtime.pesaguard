# Deployment

The included Render Blueprint is a starting point only. Review the plan, environment, region, networking, and cost before applying it.

Required environment:
- `PHX_HOST`: public hostname for the gateway.
- `SECRET_KEY_BASE`: generated secret; never commit it.
- `PESAGUARD_EVENT_INGEST_TOKEN`: unique high-entropy service token shared with the trusted backend event publisher.
- `PESAGUARD_ALLOWED_ORIGINS`: comma-separated exact dashboard origins.

Do not set the gateway as ready for production until identity verification and the event-bus consumer are implemented. The current `/health/ready` deliberately returns HTTP 503. Configure the deployment health check to `/health/live` while building; switch to readiness only after its contract is updated and all dependencies are validated.

Deployment steps:
1. Push to GitHub and review CI.
2. Create the Render service from the Blueprint without enabling customer traffic.
3. Add secrets through Render's dashboard.
4. Confirm liveness, logs, TLS, and origin policy.
5. Integrate canonical auth and the event consumer, then add integration/security tests.
6. Run cross-tenant tests and load tests.
7. Enable a small controlled rollout and retain a rollback path.
