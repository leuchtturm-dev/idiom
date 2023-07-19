defmodule IdiomTest do
  use ExUnit.Case, async: false
  import Idiom
  alias Idiom.Cache

  @data %{
    "en" => %{},
    "fr" => %{"translations" => %{"hello" => "bonjour"}}
  }

  setup_all do
    Cache.init(@data, Cache.cache_table_name())
    on_exit(fn -> :ets.delete(Cache.cache_table_name()) end)
  end

  doctest Idiom
end
