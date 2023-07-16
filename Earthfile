VERSION 0.7

ARG --global --required BASE

ci:
  BUILD +test
  BUILD +lint

setup-base:
  FROM hexpm/elixir:$BASE

  RUN apk add --no-cache build-base git
  RUN mix do local.rebar --force, \
             local.hex --force

  COPY mix.exs mix.lock .
  RUN mix deps.get

build:
  FROM +setup-base

  ENV MIX_ENV=test
  RUN mix deps.compile

  COPY --dir lib src priv .
  RUN mix compile --warnings-as-errors

test:
  FROM +build

  COPY --dir test .
  RUN mix test

lint:
  FROM +build

  COPY .formatter.exs .
  RUN mix format --check-formatted
