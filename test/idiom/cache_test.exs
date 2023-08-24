defmodule Idiom.CacheTest do
  use ExUnit.Case
  alias Idiom.Cache

  setup %{test: test} = _context do
    # NOTE:
    # We want our cache running for all tests, except for `Cache.init/2`.
    # We can pluck the currently running test out of `context` and match here to only start a testing cache when it's not for `init/2`.
    if test != :"doctest Idiom.Cache.init/2 (1)" do
      data = File.read!("test/data.json") |> Jason.decode!()
      Cache.init(data)
    end

    on_exit(fn ->
      table_name = Cache.cache_table_name()
      if :ets.info(table_name) != :undefined do
        :ets.delete(table_name)
      end
    end)

    :ok
  end

  doctest Idiom.Cache
end
