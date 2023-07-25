defmodule Idiom.Locales do
  @moduledoc """
  Utility functions for handling locales.

  Locale identifiers consist of a language code, an optional script code, and an optional region code, separated by a hyphen (-).
  """

  @doc """
  Constructs a hierarchical list of locale identifiers from the given locale.

  This function builds a list that starts with the full locale, followed by the locale with language and script without region code (if any), then the language code, and finally a fallback locale if provided.

  The `fallback` option allows you to specify a fallback locale that will be added to the end of the hierarchy if it's not already included. By default, no fallback language is included.

  ## Examples

      iex> Idiom.Locales.to_hierarchy("en-Latn-US")
      ["en-Latn-US", "en-Latn", "en"]

      iex> Idiom.Locales.to_hierarchy("de-DE", fallback: "en")
      ["de-DE", "de", "en"]
  """
  def to_hierarchy(locale, opts \\ []) do
    fallback = Keyword.get(opts, :fallback)

    ([
       locale,
       to_language_and_script(locale),
       to_language(locale)
     ] ++ List.wrap(fallback))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @doc """
  Extracts the language code from the given locale identifier.

  ## Examples

    iex> Idiom.Locales.to_language("en-Latn-US")
    "en"

    iex> Idiom.Locales.to_language("de-DE")
    "de"
  """
  def to_language(locale) do
    locale
    |> String.split("-")
    |> List.first()
  end

  @doc """
  Extracts the language and script codes from the given locale identifier.

  Returns nil if the given locale does not have a script code.

  ## Examples

      iex> Idiom.Locales.to_language_and_script("en-Latn-US")
      "en-Latn"

      iex> Idiom.Locales.to_language_and_script("de-DE")
      nil
  """
  def to_language_and_script(locale) do
    locale
    |> String.split("-")
    |> case do
      parts when is_list(parts) and length(parts) <= 2 -> nil
      parts when is_list(parts) -> Enum.take(parts, 2) |> Enum.join("-")
    end
  end
end
