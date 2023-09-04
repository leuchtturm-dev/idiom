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

  Used suffixes differ greatly by language. In order to support them all, and also make this module easier to keep up-to-date, the `PluralPreprocess` module
  parses them and generates ASTs for `cond` expressions. This module reads the definition file at compile time, and generates helper functions for each
  language.
  """
  import Idiom.PluralPreprocess

  alias Idiom.Locales

  require Logger

  @external_resource "priv/idiom/plurals.json"

  @rules "priv/idiom/plurals.json"
         |> File.read!()
         |> Jason.decode!()
         |> get_in(["supplemental", "plurals-type-cardinal"])
         |> Enum.map(fn {lang, rules} -> {lang, parse_rules(rules)} end)
         |> Map.new()

  for {locale, rules} <- @rules do
    # | ----------|-------------------------------------------------------------------|
    # | Parameter | Value                                                             |
    # | ----------|------------------------------------------------------------------ |
    # | n         | absolute value of the source number (integer/float/decimal).      |
    # | i         | integer digits of n.                                              |
    # | v         | number of visible fractional digits in n, with trailing zeros.    |
    # | w         | number of visible fractional digits in n, without trailing zeros. |
    # | f         | visible fractional digits in n, with trailing zeros.              |
    # | t         | visible fractional digits in n, without trailing zeros.           |
    # | ----------|-------------------------------------------------------------------|
    defp get_suffix(unquote(locale), n, i, v, w, f, t) do
      e = 0
      _silence_unused_warnings = {n, i, v, w, f, t, e}
      unquote(rules)
    end
  end

  defp get_suffix(locale, _n, _i, _v, _w, _f, _t) do
    Logger.warning("No plural rules found for #{locale} - returning `other`")
    "other"
  end

  @doc """
  Returns the appropriate plural suffix based on a given locale and count.

  The function will determine the correct plural form to use based on the `count` parameter.
  It supports different types of count values, including binary, float, integer and Decimal types.

  When the count is `nil`, the function will default to `other`.

  ## Examples

  ```elixir
  iex> Idiom.Plural.get_suffix("en", 1)
  "one"

  iex> Idiom.Plural.get_suffix("en", 2)
  "other"

  iex> Idiom.Plural.get_suffix("ar", 0)
  "zero"

  iex> Idiom.Plural.get_suffix("ar", "5")
  "few"

  iex> Idiom.Plural.get_suffix("ar", Decimal.new(5))
  "few"
  ```
  """
  @type count() :: binary() | float() | integer() | Decimal.t()
  @spec get_suffix(String.t(), count()) :: String.t()
  def get_suffix(locale, count)
  def get_suffix(_locale, nil), do: "other"

  def get_suffix(locale, count) when is_binary(count),
    do: get_suffix(locale, Decimal.new(count))

  def get_suffix(locale, count) when is_float(count) do
    count = count |> Float.to_string() |> Decimal.new()
    get_suffix(locale, count)
  end

  def get_suffix(locale, count) when is_integer(count) do
    locale = Locales.get_language(locale)
    n = abs(count)
    i = abs(count)
    get_suffix(locale, n, i, 0, 0, 0, 0)
  end

  def get_suffix(locale, count) do
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

    get_suffix(Locales.get_language(locale), Decimal.to_float(n), i, v, f, t, w)
  end

  defp in?(number, range) when is_integer(number) do
    number in range
  end

  defp in?(number, range) when is_float(number) do
    trunc(number) in range
  end

  defp mod(dividend, divisor) when is_float(dividend) and is_number(divisor) do
    dividend - Float.floor(dividend / divisor) * divisor
  end

  defp mod(dividend, divisor) when is_integer(dividend) and is_integer(divisor) do
    modulo =
      dividend
      |> Integer.floor_div(divisor)
      |> Kernel.*(divisor)

    dividend - modulo
  end
end
