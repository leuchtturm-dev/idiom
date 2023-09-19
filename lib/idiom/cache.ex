defmodule Idiom.Cache do
  @moduledoc """
  Cache for translations.  

  Wraps an ETS table and offers functions to insert and fetch localisation data. table
  """

  alias Idiom.Locales

  @default_table_name :idiom_cache

  @doc false
  def default_table_name, do: @default_table_name

  @doc """
  Starts a new cache.

  Allows adding initial state by passing it as first parameter.

  ## Parameters

  - `initial_state` - State to initialise the cache with. See the documentation for `insert_keys/2` for the expected format.
  - `table_name` - Name of the ETS table. Used for testing.

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
  def init(initial_state \\ %{}, table_name \\ @default_table_name) when is_map(initial_state) do
    :ets.new(table_name, [:set, :public, :named_table, read_concurrency: true])
    insert_keys(initial_state, table_name)
  end

  @doc """
  Adds a map of keys to the cache.

  ## Parameters

  - `keys` - Map of keys to add to the cache.
  - `table_name` - Name of the ETS table. Used for testing.

  ## Format of `keys`

  ```elixir
  %{
    "en" => %{"signup" => %{"Create your account" => "Create your account"}}, 
    "de" => %{"signup" => %{"Create your account" => "Erstelle deinen Account"}}}
  }
  ```

  where the first level is the locale, the second the namespace, and the third a map of the keys contained in the previous two. The keys can be nested further,
  the cache will automatically flatten them as such:

  ```elixir
  %{
    "en" => %{
      "signup" => %{
        "multiple" => %{
          "levels" => %{
            "nesting" => "Hello!"
          }
        }
      }
    }
  }
  ```

  will result in a key of `multiple.levels.nesting` inside the `signup` namespace with a message value of `Hello!`.

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
  def insert_keys(keys, table_name \\ @default_table_name) do
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
  def get_translation(locale, namespace, key, table_name \\ @default_table_name) do
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
    locale = keys |> Enum.at(0) |> Locales.format_locale()
    namespace = Enum.at(keys, 1)
    key = keys |> Enum.slice(2..-1) |> Enum.join(".")

    [{{locale, namespace, key}, value}]
  end
end
