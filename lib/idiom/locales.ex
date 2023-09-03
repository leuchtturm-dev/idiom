defmodule Idiom.Locales do
  @moduledoc """
  Utility functions for handling locales.

  Locale identifiers consist of a language code, an optional script code, and an optional region code, separated by a hyphen (-) or underscore (_).
  """

  @scripts ~w(arab cans cyrl hans hant latn mong)
  @rtl_languages ~w(ar dv fa ha he ks ps sd ur yi)

  @doc """
  Constructs a hierarchical list of locale identifiers from the given locale.

  The `fallback` option allows you to specify a fallback locale that will be added to the end of the hierarchy if it's not already included. By default, no
  fallback language is added.

  ## Examples

  ```elixir
  iex> Idiom.Locales.get_hierarchy("en-Latn-US")
  ["en-Latn-US", "en-Latn", "en"]

  iex> Idiom.Locales.get_hierarchy("de-DE", fallback: "en")
  ["de-DE", "de", "en"]
  ```
  """
  @type get_hierarchy_opts() :: [fallback: String.t() | list(String.t())]
  @spec get_hierarchy(String.t(), get_hierarchy_opts()) :: list(String.t())
  def get_hierarchy(locale, opts \\ []) when is_binary(locale) do
    fallback = Keyword.get(opts, :fallback)

    [
      format_locale(locale),
      get_language_and_script(locale),
      get_language(locale),
      fallback
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @doc """
  Extracts the language code from the given locale identifier.

  ## Examples

  ```elixir
  iex> Idiom.Locales.get_language("en-Latn-US")
  "en"

  iex> Idiom.Locales.get_language("de-DE")
  "de"
  ```
  """
  @spec get_language(String.t()) :: String.t()
  def get_language(locale) when is_binary(locale) do
    locale
    |> format_locale()
    |> String.split("-")
    |> hd()
  end

  @doc """
  Extracts the language and script codes from the given locale identifier.

  Returns `nil` if the given locale does not have a script code.

  ## Examples

  ```elixir
  iex> Idiom.Locales.get_language_and_script("en-Latn-US")
  "en-Latn"

  iex> Idiom.Locales.get_language_and_script("de-DE")
  nil
  ```
  """
  @spec get_language_and_script(String.t()) :: String.t() | nil
  def get_language_and_script(locale) when is_binary(locale) do
    locale
    |> format_locale()
    |> String.split("-")
    |> case do
      parts when length(parts) <= 2 -> nil
      parts -> Enum.take(parts, 2) |> Enum.join("-")
    end
  end

  @doc """
  Returns the writing direction of the script belonging to the locale.

  ## Examples

  ```elixir
  iex> Idiom.Locales.direction("en-US")
  :ltr

  iex> Idiom.Locales.direction("ar")
  :rtl
  ```
  """
  @spec direction(String.t()) :: :ltr | :rtl
  def direction(locale) when is_binary(locale) do
    language = get_language(locale)

    if Enum.member?(@rtl_languages, language), do: :rtl, else: :ltr
  end

  @doc """
  Formats a locale string.

  Idiom internally supports separating different parts of the locale code by either hyphen or underscore, which is then normalised by this function. Different
  locales also have different capitalisation rules, which are handled here.

  ## Examples

  ```elixir
  iex> Idiom.Locales.format_locale("de_de")
  "de-DE"

  iex> Idiom.Locales.format_locale("zh-hant-hk")
  "zh-Hant-HK"
  ```
  """
  @spec format_locale(String.t()) :: String.t()
  def format_locale(locale) when is_binary(locale) do
    locale
    |> String.downcase()
    |> String.replace("_", "-")
    |> String.split("-")
    |> case do
      [locale] ->
        [locale]

      [language, script] when script in @scripts ->
        [language, String.capitalize(script)]

      [language, region] ->
        [language, String.upcase(region)]

      [language, script, region] when script in @scripts ->
        [language, String.capitalize(script), String.upcase(region)]

      [language, region | rest] ->
        [language, String.upcase(region), Enum.join(rest, "-")]
    end
    |> Enum.join("-")
  end
end
