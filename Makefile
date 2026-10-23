.PHONY: setup test format compile server

setup:
	mix local.hex --force
	mix local.rebar --force
	mix deps.get

test:
	mix test

format:
	mix format

compile:
	mix compile --warnings-as-errors

server:
	mix phx.server
