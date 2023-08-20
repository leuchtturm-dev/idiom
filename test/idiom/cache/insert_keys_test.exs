defmodule Idiom.Cache.InsertKeysTest do
  use ExUnit.Case, async: true
  alias Idiom.Cache

  @cache_table_name :insert_keys_test

  setup do
    initial_state = File.read!("test/data.json") |> Jason.decode!()
    Cache.init(initial_state, @cache_table_name)
  end

  test "flattens data with colon separating locale, namespace and key" do
    data = %{"en" => %{"default" => %{"foo" => "bar"}}, "de" => %{"default" => %{"bar" => "baz"}}}
    Cache.insert_keys(data, @cache_table_name)
    cache_state = Map.new(:ets.tab2list(@cache_table_name))

    assert %{{"en", "default", "foo"} => "bar", {"de", "default", "bar"} => "baz"} = cache_state
  end

  test "flattens nested keys with dot separator" do
    data = %{"en" => %{"default" => %{"foo" => %{"bar" => %{"baz" => "what even comes after baz"}}}}}
    Cache.insert_keys(data, @cache_table_name)
    cache_state = Map.new(:ets.tab2list(@cache_table_name))

    assert %{{"en", "default", "foo.bar.baz"} => "what even comes after baz"} = cache_state
  end

  test "overwrites existing keys" do
    data = %{"en" => %{"default" => %{"foo" => "baz"}}}
    Cache.insert_keys(data, @cache_table_name)
    cache_state = Map.new(:ets.tab2list(@cache_table_name))

    assert %{{"en", "default", "foo"} => "baz"} = cache_state
  end

  test "does not delete existing keys" do
    data = %{"en" => %{"default" => %{"foo" => "baz"}}}
    Cache.insert_keys(data, @cache_table_name)
    cache_state = Map.new(:ets.tab2list(@cache_table_name))

    assert %{{"en", "default", "deep.foo"} => "Deep bar"} = cache_state
  end
end
