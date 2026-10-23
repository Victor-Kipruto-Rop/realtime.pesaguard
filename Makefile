.PHONY: setup deps test format format-check compile check server docker-build

setup:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get

deps:
	mix deps.get

test:
	mix test

format:
	mix format

format-check:
	mix format --check-formatted

compile:
	mix compile --warnings-as-errors

check: format-check compile test

server:
	mix phx.server

docker-build:
	docker build --tag realtime-pesaguard:local .
