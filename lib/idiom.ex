defmodule Idiom do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  import Idiom.Interpolation

  alias Idiom.Cache
  alias Idiom.Extract
  alias Idiom.Locales
  alias Idiom.Plural

  require Logger

  @external_resource "README.md"

  @doc false
  defdelegate child_spec(options), to: Idiom.Supervisor

  defdelegate direction(locale), to: Locales

  @type translate_opts() :: [
          namespace: String.t(),
          to: String.t(),
          fallback: String.t() | list(String.t()),
          count: integer() | float() | Decimal.t() | String.t(),
          plural: :cardinal | :ordinal,
          cache_table_name: atom()
        ]

  @doc """
  Alias of `t/3` for when you don't need any bindings.
  """
  @spec t(String.t() | list(String.t()), translate_opts()) :: String.t()
  def t(key_or_keys, opts) when is_list(opts), do: t(key_or_keys, %{}, opts)

  @doc """
  Translates a key into a target language.

  ## Examples

  ```elixir
  iex> Idiom.t("hello", to: "es")
  "hola"

  # With process-wide locale
  iex> Idiom.put_locale("fr")
  iex> Idiom.t("hello")
  "bonjour"

  # If neither `:to` option is provided nor `:lang` is set in the process, it will check the application configuration:
  # Given `config :idiom, default_lang: "en"` is set in the `config.exs` file:
  iex> Idiom.t("hello")
  "hello"

  # If a key does not exist in the target language, it will use the `:fallback` option:
  iex> Idiom.t("hello", to: "de", fallback: "fr")
  "bonjour"

  # If a key does not exist in the target language or the first fallback language:
  iex> Idiom.t("hello", to: "de", fallback: ["pl", "fr"])
  "bonjour"
  ```
  """

  @spec t(String.t() | list(String.t()), map(), translate_opts()) :: String.t()
  def t(key_or_keys, bindings \\ %{}, opts \\ []) do
    locale = Keyword.get(opts, :to) || get_locale()
    namespace = Keyword.get(opts, :namespace) || get_namespace()

    run_t(locale, namespace, key_or_keys, bindings, opts)
  end

  defp run_t(locale, namespace, key_or_keys, _binding, _opts)
       when is_nil(locale) or is_nil(namespace) do
    Logger.warning("""
    Idiom: Called `t/3` without a locale or namespace set. You can configure a default locale and namespace by adding

      config :idiom,
        default_locale: "en",
        default_namespace: "default"

    to your configuration.  
    Returning the key untranslated: #{fallback_message(key_or_keys)}
    """)

    fallback_message(key_or_keys)
  end

  defp run_t(locale, namespace, key_or_keys, bindings, opts) do
    fallback =
      Keyword.get(opts, :fallback) || Application.get_env(:idiom, :default_fallback)

    count = Keyword.get(opts, :count)
    plural = Keyword.get(opts, :plural)
    bindings = Map.put_new(bindings, :count, count)

    locale_resolve_hierarchy =
      [locale | List.wrap(fallback)]
      |> Enum.map(&Locales.get_hierarchy/1)
      |> List.flatten()
      |> Enum.uniq()

    lookup_keys =
      Enum.reduce(locale_resolve_hierarchy, [], fn locale, acc ->
        pluralised_keys =
          key_or_keys
          |> List.wrap()
          |> Enum.flat_map(fn key ->
            [
              {locale, namespace, key},
              {locale, namespace, "#{key}_#{Plural.get_suffix(locale, count, type: plural)}"}
            ]
          end)

        acc ++ pluralised_keys
      end)

    cache_table_name = Keyword.get(opts, :cache_table_name, Cache.default_table_name())

    lookup_keys
    |> Enum.find_value(fallback_message(key_or_keys), fn {locale, namespace, key} ->
      Cache.get_translation(locale, namespace, key, cache_table_name)
    end)
    |> interpolate(bindings)
  end

  @doc """
  Returns the locale that will be used by `t/3`.

  ## Examples

  ```elixir
  iex> Idiom.get_locale()
  "en-US"
  ```
  """
  @spec get_locale() :: String.t()
  def get_locale do
    Process.get(:idiom_locale) || Application.get_env(:idiom, :default_locale)
  end

  @doc """
  Sets the locale for the current process.

  ## Examples

  ```elixir
  iex> Idiom.put_locale("fr-FR")
  "fr-FR"
  ```
  """
  @spec put_locale(String.t()) :: String.t()
  def put_locale(locale) when is_binary(locale) do
    Process.put(:idiom_locale, locale)

    locale
  end

  @doc """
  Returns the namespace that will be used by `t/3`.

  ## Examples

  ```elixir
  iex> Idiom.get_namespace()
  "default"
  ```
  """
  @spec get_namespace() :: String.t()
  def get_namespace do
    Process.get(:idiom_namespace) || Application.get_env(:idiom, :default_namespace)
  end

  @doc """
  Sets the namespace for the current process.

  ## Examples

  ```elixir
  iex> Idiom.put_namespace("signup")
  "signup"
  ```
  """
  @spec put_namespace(String.t()) :: String.t()
  def put_namespace(namespace) when is_binary(namespace) do
    Process.put(:idiom_namespace, namespace)

    namespace
  end

  @doc false
  defmacro __using__(_opts) do
    quote unquote: false do
      defmacro t_extract(key, opts) do
        if Application.get_env(:idiom, :extracting?, false) and is_binary(key) do
          file = __CALLER__.file
          key = Extract.expand_to_binary(key, __CALLER__)
          namespace = opts |> Keyword.get(:namespace) |> Extract.expand_to_binary(__CALLER__)
          has_count? = Keyword.has_key?(opts, :count)
          plural_type = Keyword.get(opts, :plural, :cardinal)

          Idiom.Extract.add_key(%{
            file: file,
            key: key,
            namespace: namespace,
            has_count?: has_count?,
            plural_type: plural_type
          })
        end
      end

      defmacro t(key, opts) when is_list(opts) do
        quote do
          unquote(__MODULE__).t_extract(unquote(key), unquote(opts))

          Idiom.t(unquote(key), %{}, unquote(opts))
        end
      end

      defmacro t(key, bindings \\ Macro.escape(%{}), opts \\ Macro.escape([])) do
        quote do
          unquote(__MODULE__).t_extract(unquote(key), unquote(opts))

          Idiom.t(unquote(key), unquote(bindings), unquote(opts))
        end
      end
    end
  end

  defp fallback_message(key_or_keys)
  defp fallback_message(key) when is_binary(key), do: key
  defp fallback_message(keys) when is_list(keys), do: List.first(keys)
end
