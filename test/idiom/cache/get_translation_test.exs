defmodule Idiom.Cache.GetTranslationTest do
  use ExUnit.Case, async: true
  alias Idiom.Cache

  @cache_table_name :get_translation_test

  setup_all do
    initial_state = File.read!("test/data.json") |> Jason.decode!()
    Cache.init(initial_state, @cache_table_name)
  end

  tests = [
    %{locale: "en", namespace: "default", key: "foo", expected: "bar"},
    %{locale: "en", namespace: "default", key: "deep.foo", expected: "Deep bar"},
    %{locale: "en", namespace: "default", key: "Natural language: the colon-ing", expected: "Colons"},
    %{locale: "en", namespace: "default", key: "carrot_one", expected: "1 carrot"},
    %{locale: "en", namespace: "default", key: "carrot_other", expected: "{{count}} carrots"},
    %{locale: "de", namespace: "default", key: "butterfly", expected: "Schmetterling"}
  ]

  describe "when key exists for locale and namespace" do
    for %{locale: locale, namespace: namespace, key: key, expected: expected} <- tests do
      test "correctly retrieves key #{key} from cache" do
        assert Cache.get_translation(unquote(locale), unquote(namespace), unquote(key), @cache_table_name) == unquote(expected)
      end
    end
  end

  describe "when key does not exist" do
    test "returns nil" do
      refute Cache.get_translation("en", "default", "bar", @cache_table_name)
    end
  end
end
