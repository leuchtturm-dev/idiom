defmodule Idiom.IdiomTest do
  use ExUnit.Case, async: true
  alias Idiom.Cache

  setup do
    File.read!("test/data.json")
    |> Jason.decode!()
    |> Cache.init()

    :ets.tab2list(Cache.cache_table_name)
  end

  doctest Idiom
end
