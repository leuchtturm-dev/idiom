defmodule Idiom.Cache do
  @moduledoc """
  Cache for translations.

  Idiom supports multiple sources for translations. It comes out of the box with a few, but also allows anyone to add another source as an external plugin. To
  keep performance up and also have a shared state for all sources, it is using an ETS as a cache. This is a public that can be written to from any other
  source module.  
  The cache holds translations with the following key format: `{locale}:{domain}:{key}`, e.g. `en-US:signup:Create your account`  
  It provides a helper function, `map_to_cache_data/4`, to Elixir maps into this format, allowing easily adding new keys.
  """
  @cache_table_name :idiom_cache

  @doc false
  def cache_table_name, do: @cache_table_name

  @doc """
  Starts a new cache.

  Allows adding initial state by passing it as first parameter.

  ## Examples

  ```elixir
  iex> initial_state = %{"en" => %{"signup" => %{"Create your account" => "Create your account"}}, "de" => %{"signup" => %{"Create your account" => "Erstelle deinen Account"}}}
  iex> Idiom.Cache.init(initial_state)
  :ok
  ```
  """
  @spec init(map(), atom()) :: :ok
  def init(initial_state \\ %{}, table_name \\ @cache_table_name) when is_map(initial_state) do
    start(table_name)
    insert_keys(initial_state, table_name)
  end

  defp start(table_name), do: :ets.new(table_name, [:public, :named_table, read_concurrency: true])

  # TODO:
  @doc """
  """
  def insert_keys(keys, table_name \\ @cache_table_name) do
    keys
    |> map_to_cache_data()
    |> Enum.each(fn {key, value} ->
      :ets.insert(table_name, {key, value})
    end)
  end

  # TODO:
  @doc """
  """
  def get_key(cache_key, table_name \\ @cache_table_name) do
    case :ets.lookup(table_name, cache_key) do
      [{^cache_key, translation}] -> translation
      [] -> nil
    end
  end

  # TODO:
  @doc """
  """
  def get_translation(language, namespace, key, table_name \\ @cache_table_name) do
    to_cache_key(language, namespace, key)
    |> get_key(table_name)
  end

  # TODO:
  @doc """
  """
  def to_cache_key(language, namespace, key), do: "#{language}:#{namespace}:#{key}"

  # Input: %{en: %{translation: %{"foo.baz" => "bar"}}, de: %{login: %{bar: "baz", foo: %{bar: "baz"}}}}}}
  # Output: %{"en:translation:foo.baz" => "bar", "de:login:bar" => "baz", "de:login:foo.bar" => "baz"}
  def map_to_cache_data(map, acc \\ %{}, prefix \\ "", depth \\ 0) do
    Enum.reduce(map, acc, fn {key, value}, acc ->
      separator = if depth < 3, do: ":", else: "."
      new_key = if prefix == "", do: to_string(key), else: prefix <> separator <> to_string(key)

      case value do
        %{} ->
          map_to_cache_data(value, acc, new_key, depth + 1)

        _ ->
          Map.put(acc, new_key, value)
      end
    end)
  end
end
