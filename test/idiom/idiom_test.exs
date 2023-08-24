defmodule Idiom.IdiomTest do
  use ExUnit.Case, async: true
  alias Idiom.Cache

  setup_all do
    File.read!("test/data.json")
    |> Jason.decode!()
    |> Cache.init()
  end

  doctest Idiom
end
