# Phase 06 Prompt — Real-Time Routing and Delivery

## Mission
Route only validated, authorized events to the correct tenant's Phoenix channel with bounded resource use and honest delivery semantics.

## Mandatory context
Read the universal prompt rules, approved event contract, tenant authorization implementation, transport adapter and relevant channel, event-driven, performance and testing skills.

## Execute
1. Trace an event from consumer through validation and routing to Phoenix PubSub/Channels. Ensure every hop preserves the trusted tenant context.
2. Map allow-listed event types to explicitly authorized delivery topics. Derive topic names server-side; never broadcast to a client-chosen topic.
3. Define the client envelope and behavior for unsupported types, duplicate events, invalid tenant scope, disconnected clients and publisher errors.
4. Bound payload size, fan-out, queueing and per-connection memory. Define slow-client/backpressure behavior and protect against reconnect storms.
5. Document heartbeat, reconnect, resubscribe and stale-connection handling. Clarify that WebSocket delivery is ephemeral unless separate persistence/acknowledgement provides stronger guarantees.
6. Test the end-to-end producer-to-broker-to-router-to-channel path with real contract fixtures and authorized test identities.
7. Prove that a tenant-A event cannot reach tenant-B, including through retries, fan-out, stale connections and malformed routing metadata.

## Scope lock
Do not add unsupported event types, make the gateway a financial system of record, or claim durable client receipt without an actual acknowledgement/persistence design.

## Acceptance checklist
- [ ] Routing uses only approved event types and validated envelopes.
- [ ] Topic scope is server-derived and authorization is enforced.
- [ ] End-to-end authorized delivery test passes.
- [ ] Cross-tenant delivery tests pass for normal and failure paths.
- [ ] Duplicate/unsupported events and publish failures are handled safely.
- [ ] Backpressure and connection lifecycle behavior are bounded/documented.
- [ ] Delivery guarantees match the actual implementation.

## Required closeout
Update routing documentation and Phase 06 checklist. Do not proceed to dashboard integration until the server-side path is verified.

## Follow-up prompt
“Trace and test each event delivery path from broker record to socket subscriber. Attempt cross-tenant routing, duplicate fan-out and slow-client resource exhaustion; fix defects, rerun tests and report exactly what was proven.”
