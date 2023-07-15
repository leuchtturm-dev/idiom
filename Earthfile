VERSION 0.7

ARG --global --required ELIXIR_VERSION
ARG --global --required OTP_VERSION

ci:
  BUILD +test
  BUILD +lint

setup-base:
  FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$OTP_VERSION-alpine-3.18.2

  RUN apk add --no-cache build-base git
  RUN mix do local.rebar --force, \
             local.hex --force

  COPY mix.exs mix.lock .
  RUN mix deps.get

build:
  FROM +setup-base

  ENV MIX_ENV=test
  RUN mix deps.compile

  COPY --dir lib .
  RUN mix compile --warnings-as-errors

test:
  FROM +build

  COPY --dir test .
  RUN mix test

lint:
  FROM +build

  COPY .formatter.exs .
  RUN mix format --check-formatted
