defmodule Idiom.Plural do
  @moduledoc """
  Functionality for handling plurals and plural suffixes.

  Idiom handles plurals by adding suffixes to keys. These suffixes are as defined by the Unicode CLDR plural rules:
  - `zero`
  - `one`
  - `two`
  - `few`
  - `many`
  - `other`

  Used suffixes differ greatly by language. In order to support them all, and also make this module easier to keep up-to-date, the `PluralAST` module
  parses them and generates ASTs for `cond` expressions. This module reads the definition file at compile time, and generates helper functions for each
  language.
  """
  import Idiom.PluralAST

  alias Idiom.Locales

  require Logger

  @external_resource "priv/idiom/plurals-cardinal.json"
  @external_resource "priv/idiom/plurals-ordinal.json"

  @cardinal_suffixes "cardinal"
                     |> fetch_rules()
                     |> get_suffixes()

  @cardinal_rules "cardinal"
                  |> fetch_rules()
                  |> Enum.map(fn {lang, rules} -> {lang, parse_rules(rules)} end)
                  |> Map.new()

  @ordinal_suffixes "ordinal"
                    |> fetch_rules()
                    |> get_suffixes()

  @ordinal_rules "ordinal"
                 |> fetch_rules()
                 |> Enum.map(fn {lang, rules} -> {lang, parse_rules(rules)} end)
                 |> Map.new()

  for {locale, rules} <- @cardinal_rules do
    # Source: http://unicode.org/reports/tr35/tr35-numbers.html#Operands
    # | ----------|--------------------------------------------------------------------------------------------- |
    # | Parameter | Value                                                                                        |
    # | ----------|--------------------------------------------------------------------------------------------- |
    # | n         | the absolute value of N                                                                      |
    # | i         | the integer digits of N                                                                      |
    # | v         | the number of visible fraction digits in N, with trailing zeros                              |
    # | w         | the number of visible fraction digits in N, without trailing zeros                           |
    # | f         | the visible fraction digits in N, with trailing zeros, expressed as an integer               |
    # | t         | the visible fraction digits in N, without trailing zeros, expressed as an integer            |
    # | ----------|--------------------------------------------------------------------------------------------- |
    defp get_cardinal_suffix(unquote(locale), n, i, v, w, f, t) do
      # c/e are not used
      e = 0

      _silence_unused_variable_warnings = {n, i, v, w, f, t, e}

      unquote(rules)
    end
  end

  defp get_cardinal_suffix(locale, _n, _i, _v, _w, _f, _t) do
    Logger.warning("No plural rules found for #{locale} - returning `other`")

    "other"
  end

  for {locale, rules} <- @ordinal_rules do
    # Source: http://unicode.org/reports/tr35/tr35-numbers.html#Operands
    # | ----------|--------------------------------------------------------------------------------------------- |
    # | Parameter | Value                                                                                        |
    # | ----------|--------------------------------------------------------------------------------------------- |
    # | n         | the absolute value of N                                                                      |
    # | i         | the integer digits of N                                                                      |
    # | v         | the number of visible fraction digits in N, with trailing zeros                              |
    # | w         | the number of visible fraction digits in N, without trailing zeros                           |
    # | f         | the visible fraction digits in N, with trailing zeros, expressed as an integer               |
    # | t         | the visible fraction digits in N, without trailing zeros, expressed as an integer            |
    # | ----------|--------------------------------------------------------------------------------------------- |
    defp get_ordinal_suffix(unquote(locale), n, i, v, w, f, t) do
      # c/e are not used
      e = 0

      _silence_unused_variable_warnings = {n, i, v, w, f, t, e}

      unquote(rules)
    end
  end

  defp get_ordinal_suffix(locale, _n, _i, _v, _w, _f, _t) do
    Logger.warning("No plural rules found for #{locale} - returning `other`")

    "other"
  end

  @doc """
  Returns the appropriate plural suffix based on a given locale, count and plural type.

  The function will determine the correct plural form to use based on the `count` 
  parameter. It supports different types of count values, including binary, float, 
  integer and Decimal types.

  It also allows selecting whether you want to receive the suffix for cardinal or
  ordinal plurals by passing `:cardinal` or `:ordinal` as the `type` option, where
  cardinal is the default plural type.

  When the count is `nil`, the function will default to `other`.

  ## Examples

  ```elixir
  iex> Idiom.Plural.get_suffix("en", 1)
  "one"

  iex> Idiom.Plural.get_suffix("en", 2, type: :cardinal)
  "other"

  iex> Idiom.Plural.get_suffix("en", 2, type: :ordinal)
  "two"

  iex> Idiom.Plural.get_suffix("ar", 0)
  "zero"

  iex> Idiom.Plural.get_suffix("ar", "5")
  "few"

  iex> Idiom.Plural.get_suffix("ar", Decimal.new(5))
  "few"
  ```
  """
  @type count() :: binary() | float() | integer() | Decimal.t()
  @spec get_suffix(String.t(), count(), type: :cardinal | :ordinal) :: String.t()
  def get_suffix(locale, count, opts \\ [])
  def get_suffix(_locale, nil, _opts), do: "other"

  def get_suffix(locale, count, opts) when is_binary(count) do
    get_suffix(locale, Decimal.new(count), opts)
  end

  def get_suffix(locale, count, opts) when is_float(count) do
    count = count |> Float.to_string() |> Decimal.new()

    get_suffix(locale, count, opts)
  end

  def get_suffix(locale, count, opts) when is_integer(count) do
    locale = Locales.get_language(locale)
    n = abs(count)
    i = abs(count)

    plural_type = Keyword.get(opts, :type) || :cardinal

    get_suffix(plural_type, locale, n, i, 0, 0, 0, 0)
  end

  def get_suffix(locale, count, opts) do
    n = Decimal.abs(count)
    i = count |> Decimal.round(0, :floor) |> Decimal.to_integer()
    v = abs(n.exp)

    mult = 10 |> Integer.pow(v) |> Decimal.new()

    f =
      n
      |> Decimal.sub(i)
      |> Decimal.mult(mult)
      |> Decimal.round(0, :floor)
      |> Decimal.to_integer()

    t =
      f
      |> Integer.to_string()
      |> String.trim_trailing("0")
      |> case do
        "" -> 0
        other -> other |> Decimal.new() |> Decimal.to_integer()
      end

    w =
      f
      |> Integer.to_string()
      |> String.trim_trailing("0")
      |> String.length()

    plural_type = Keyword.get(opts, :type, :cardinal)

    get_suffix(
      plural_type,
      Locales.get_language(locale),
      Decimal.to_float(n),
      i,
      v,
      f,
      t,
      w
    )
  end

  @doc """
  Returns a locale's plural suffixes for the specific plural type.

  ## Examples

  ```elixir
  iex> Idiom.Plural.get_suffixes("en-US", :cardinal)
  ["one", "other"]

  iex> Idiom.Plural.get_suffixes("en-US", :ordinal)
  ["one", "two", "few", "other"]
  ```
  """
  @spec get_suffixes(String.t(), :cardinal | :ordinal) :: String.t()
  def get_suffixes(locale, type)

  def get_suffixes(locale, :cardinal) do
    language = Locales.get_language(locale)

    Map.get(@cardinal_suffixes, language, ["other"])
  end

  def get_suffixes(locale, :ordinal) do
    language = Locales.get_language(locale)

    Map.get(@ordinal_suffixes, language, ["other"])
  end

  defp get_suffix(:cardinal, locale, n, i, v, w, f, t),
    do: get_cardinal_suffix(locale, n, i, v, w, f, t)

  defp get_suffix(:ordinal, locale, n, i, v, w, f, t),
    do: get_ordinal_suffix(locale, n, i, v, w, f, t)

  defp in?(number, range) when is_integer(number) do
    number in range
  end

  defp in?(number, range) when is_float(number) do
    trunc(number) in range
  end

  defp mod(dividend, divisor) when is_float(dividend) and is_number(divisor) do
    dividend - Float.floor(dividend / divisor) * divisor
  end

  defp mod(dividend, divisor) when is_integer(dividend) and is_integer(divisor),
    do: Integer.mod(dividend, divisor)
end
