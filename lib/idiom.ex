defmodule Idiom do
  @moduledoc """
  Test
  """

  import Idiom.Interpolation
  alias Idiom.Cache
  alias Idiom.Locales
  alias Idiom.Plural
  require Logger

  defdelegate child_spec(options), to: Idiom.Supervisor

  @doc "Alias for `translate/3`"
  def t(key, opts) when is_list(opts), do: t(key, %{}, opts)

  @doc "Alias for `translate/3`"
  def t(key, bindings \\ %{}, opts \\ []), do: translate(key, bindings, opts)

  @type translate_opts() :: [to: String.t(), fallback: String.t() | list(String.t())]
  @doc """
  Translates a key into a target language.

  The `translate/2` function takes two arguments:
  - `key`: The specific key for which the translation is required.
  - `opts`: An optional list of options.

  ## Target and fallback languages

  For both target and fallback languages, the selected options are based on the following order of priority:
  1. The `:to` and `:fallback` keys in `opts`.
  2. The `:locale` and `:fallback` keys in the current process dictionary.
  3. The application configuration's `:default_locale` and `:default_fallback` keys.

  The language needs to be a single string, whereas the fallback can both be a single string or a list of strings.

  ## Namespaces

  Keys can be namespaced. ... write stuff here

  ## Configuration

  Application-wide configuration can be set in `config.exs` like so:

  ```elixir
  config :idiom,
    default_locale: "en",
    default_fallback: "fr"
    # default_fallback: ["fr", "es"]
  ```

  ## Examples

      iex> translate("hello", to: "es")
      "hola"

      # If no `:to` option is provided, it will check the process dictionary:
      iex> Process.put(:lang, "fr")
      iex> translate("hello")
      "bonjour"

      # If neither `:to` option is provided nor `:lang` is set in the process, it will check the application configuration:
      # Given `config :idiom, default_lang: "en"` is set in the `config.exs` file:
      iex> translate("hello")
      "hello"

      # If a key does not exist in the target language, it will use the `:fallback` option:
      iex> translate("hello", to: "de", fallback: "fr")
      "bonjour"

      # If a key does not exist in the target language or the first fallback language:
      iex> translate("hello", to: "de", fallback: ["pl", "fr"])
      "bonjour"
  """

  def translate(key, bindings \\ %{}, opts \\ [])

  @spec translate(String.t(), map(), translate_opts()) :: String.t()
  def translate(key, bindings, opts) do
    lang = Keyword.get(opts, :to) || Process.get(:locale) || Application.get_env(:idiom, :default_locale)
    fallback = Keyword.get(opts, :fallback) || Process.get(:fallback) || Application.get_env(:idiom, :default_fallback)
    count = Keyword.get(opts, :count)
    {namespace, key} = extract_namespace(key, opts)

    resolve_hierarchy =
      [lang | List.wrap(fallback)]
      |> Enum.map(&Locales.to_hierarchy/1)

    keys =
      Enum.reduce(resolve_hierarchy, [], fn lang, acc ->
        acc ++ [Cache.to_cache_key(lang, namespace, key), Cache.to_cache_key(lang, namespace, "#{key}_#{Plural.get_suffix(lang, count)}")]
      end)

    cache_table_name = Keyword.get(opts, :cache_table_name, Cache.cache_table_name())

    Enum.find_value(keys, key, fn key -> Cache.get_key(key, cache_table_name) end)
    |> interpolate(bindings)
  end

  @doc false
  defp extract_namespace(key, opts) do
    namespace_from_opts = Keyword.get(opts, :namespace) || Process.get(:namespace) || Application.get_env(:idiom, :default_namespace)
    namespace_separator = Keyword.get(opts, :namespace_separator, ":")
    key_separator = Keyword.get(opts, :key_separator, ".")

    if String.contains?(key, namespace_separator) do
      [namespace | key_parts] = String.split(key, namespace_separator)

      if is_binary(Keyword.get(opts, :namespace)) or is_binary(Process.get(:namespace)) do
        Logger.warning("Namespace was set in options/process, but key #{key} already includes a namespace. Using the key's namespace: #{namespace}.")
      end

      {namespace, Enum.join(key_parts, key_separator)}
    else
      {namespace_from_opts, key}
    end
  end
end
