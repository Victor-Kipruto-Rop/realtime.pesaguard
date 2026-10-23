# API Design Skill

Define method, path, authentication, authorization, request and response schemas, status codes and error model. Validate inputs at boundaries. Use stable machine-readable error codes, bounded pagination, idempotency for retryable writes, request limits, correlation IDs, documented rate limits and a version/deprecation policy. Avoid leaking stack traces, secrets or another tenant's existence. Keep OpenAPI/docs synchronized and test authorization and compatibility.

For internal event endpoints, require service authentication and trusted tenant context. A browser-provided tenant ID is never authorization.
