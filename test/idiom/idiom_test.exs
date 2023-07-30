defmodule Idiom.IdiomTest do
  use ExUnit.Case, async: true
  alias Idiom.Cache

  setup do
    data = File.read!("test/data.json") |> Jason.decode!()
    Cache.init(data)
  end

  doctest Idiom
end
