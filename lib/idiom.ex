defmodule Idiom do
  alias Idiom.Cache
  alias Idiom.Languages
  alias Idiom.Plural

  defdelegate child_spec(options), to: Idiom.Supervisor

  @doc "Alias for `translate/2`"
  def t(key, opts \\ []), do: translate(key, opts)

  @type translate_opts() :: [to: String.t(), fallback: String.t() | list(String.t())]
  @doc """
  Translates a key into a target language.

  The `translate/2` function takes two arguments:
  - `key`: The specific key for which the translation is required.
  - `opts`: An optional list of options.

  ## Target and fallback languages

  For both target and fallback languages, the selected options are based on the following order of priority:
  1. The `:to` and `:fallback` keys in `opts`.
  2. The `:lang` and `:fallback` keys in the current process dictionary.
  3. The application configuration's `:default_lang` and `:default_fallback` keys.

  The language needs to be a single string, whereas the fallback can both be a single string or a list of strings.

  ## Namespaces

  Keys can be namespaced.

  ## Configuration

  Application-wide configuration can be set in `config.exs` like so:

  ```elixir
  config :idiom,
    default_lang: "en",
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
  @spec translate(String.t(), translate_opts()) :: String.t()
  def translate(key, opts \\ []) do
    lang = Keyword.get(opts, :to) || Process.get(:lang) || Application.get_env(:idiom, :default_lang)

    translate(lang, key, opts)
  end

  defp translate(lang, key, opts)
  defp translate(_lang, nil, _opts), do: ""

  defp translate(lang, key, opts) do
    cache_table_name = Keyword.get(opts, :cache_table_name, Cache.cache_table_name())

    count = Keyword.get(opts, :count)
    {namespace, key} = extract_namespace(key, opts)
    langs = Languages.to_resolve_hierarchy(lang, opts)

    keys =
      Enum.reduce(langs, [], fn lang, acc ->
        acc ++ [Cache.to_cache_key(lang, namespace, key), Cache.to_cache_key(lang, namespace, "#{key}_#{Plural.get_suffix(lang, count)}")]
      end)

    Enum.find_value(keys, fn key -> Cache.get_key(key, cache_table_name) end)
  end

  @doc false
  defp extract_namespace(key, opts) do
    default_namespace = Keyword.get(opts, :default_namespace, "translations")
    namespace_separator = Keyword.get(opts, :namespace_separator, ":")
    key_separator = Keyword.get(opts, :key_separator, ".")

    if String.contains?(key, namespace_separator) do
      [namespace | key_parts] = String.split(key, namespace_separator)
      {namespace, Enum.join(key_parts, key_separator)}
    else
      {default_namespace, key}
    end
  end
end
