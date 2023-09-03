defmodule Idiom.Cache do
  @moduledoc """
  Cache for translations.
  Idiom is flexible in terms of which source translations can be retrieved from. It comes with a few different ones out of the box, and can also be extended
  through plugins. `Idiom.Cache` provides utilities to interact with the ETS that acts as a central storage for translations, both for adding/updating keys
  and retrieving values. table
  """

  alias Idiom.Locales

  @cache_table_name :idiom_cache

  @doc false
  def cache_table_name, do: @cache_table_name

  @doc """
  Starts a new cache.

  Allows adding initial state by passing it as first parameter.

  ## Examples

  ```elixir
  iex> initial_state = %{
  ...>  "en" => %{"signup" => %{"Create your account" => "Create your account"}}, 
  ...>  "de" => %{"signup" => %{"Create your account" => "Erstelle deinen Account"}}
  ...>}
  iex> Idiom.Cache.init(initial_state)
  :ok

  iex> Idiom.Cache.init(%{}, :different_cache_name)
  :ok
  ```
  """
  @spec init(map(), atom()) :: :ok
  def init(initial_state \\ %{}, table_name \\ @cache_table_name) when is_map(initial_state) do
    :ets.new(table_name, [:set, :public, :named_table, read_concurrency: true, decentralized_counters: true])
    insert_keys(initial_state, table_name)
  end

  @doc """
  Adds a map of keys to the cache.

  ## Examples

  ```elixir
  iex> Idiom.Cache.insert_keys(%{
  ...>  "en" => %{"signup" => %{"Create your account" => "Create your account"}}, 
  ...>  "de" => %{"signup" => %{"Create your account" => "Erstelle deinen Account"}}}
  ...>)
  :ok
  ```
  """
  @spec insert_keys(map(), atom()) :: :ok
  def insert_keys(keys, table_name \\ @cache_table_name) do
    keys
    |> map_to_cache_data([])
    |> Enum.each(fn {key, value} ->
      :ets.insert(table_name, {key, value})
    end)

    :ok
  end

  @doc """
  Retrieves a translation from the cache.

  ## Examples

  ```elixir
  iex> Cache.get_translation("de", "default", "butterfly")
  "Schmetterling"
  ```
  """
  @spec get_translation(String.t(), String.t(), String.t(), atom()) :: String.t() | nil
  def get_translation(locale, namespace, key, table_name \\ @cache_table_name) do
    case :ets.lookup(table_name, {locale, namespace, key}) do
      [{{^locale, ^namespace, ^key}, translation}] -> translation
      [] -> nil
    end
  end

  defp map_to_cache_data(value, keys) when is_map(value) do
    Enum.flat_map(value, fn {key, value} ->
      map_to_cache_data(value, keys ++ [key])
    end)
  end

  defp map_to_cache_data(value, keys) when is_binary(value) do
    locale = Enum.at(keys, 0) |> Locales.format_locale()
    namespace = Enum.at(keys, 1)
    key = Enum.slice(keys, 2..-1) |> Enum.join(".")

    [{{locale, namespace, key}, value}]
  end
end
