defmodule Idiom.Locales do
  @moduledoc """
  Utility functions for handling locales.

  Locale identifiers consist of a language code, an optional script code, and an optional region code, separated by a hyphen (-).
  """

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
  def get_hierarchy(locale, opts \\ []) do
    fallback = Keyword.get(opts, :fallback)

    [
      locale,
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
    case String.split(locale, "-") do
      parts when length(parts) <= 2 -> nil
      parts -> Enum.take(parts, 2) |> Enum.join("-")
    end
  end
end
