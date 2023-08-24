VERSION 0.7
PROJECT cschmatzler/idiom

ci:
  PIPELINE
  TRIGGER push main
  TRIGGER pr main

  BUILD +run --BASE=1.15.4-erlang-26.0.2-debian-bookworm-20230612-slim
  BUILD +run --BASE=1.15.4-erlang-25.3.2.2-debian-bookworm-20230612-slim
  BUILD +run --BASE=1.15.4-erlang-24.3.4.9-debian-bookworm-20230612-slim
  BUILD +run --BASE=1.14.5-erlang-26.0.2-debian-bookworm-20230612-slim
  BUILD +run --BASE=1.14.5-erlang-25.3.2.2-debian-bookworm-20230612-slim
  BUILD +run --BASE=1.14.5-erlang-24.3.4.9-debian-bookworm-20230612-slim
  BUILD +run --BASE=1.13.4-erlang-25.3.2.2-debian-bookworm-20230612-slim
  BUILD +run --BASE=1.13.4-erlang-24.3.4.9-debian-bookworm-20230612-slim

run:
  ARG --required BASE

  BUILD +test --BASE=$BASE
  BUILD +lint --BASE=$BASE
  BUILD +typespecs --BASE=$BASE

setup-base:
  ARG --required BASE

  FROM hexpm/elixir:$BASE

  RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*
  RUN mix do local.rebar --force, \
             local.hex --force

  WORKDIR /idiom

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

  COPY .credo.exs .formatter.exs .
  RUN mix format --check-formatted
  RUN mix credo

typespecs:
  FROM +build

  RUN mix dialyzer
