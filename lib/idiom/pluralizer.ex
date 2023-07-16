defmodule Idiom.Pluralizer do
  require Logger

  alias Idiom.Pluralizer.Parser
  alias Idiom.Pluralizer.AST

  import Idiom.Pluralizer.Util

  @rules [:code.priv_dir(Mix.Project.config()[:app]), "/idiom"]
         |> :erlang.iolist_to_binary()
         |> Path.join("/plurals.json")
         |> File.read!()
         |> Jason.decode!()
         |> get_in(["supplemental", "plurals-type-cardinal"])
         |> Enum.map(&Parser.parse_rules/1)
         |> Map.new()

  for {lang, rules} <- @rules do
    # Parameter | Value
    # ----------|------------------------------------------------------------------
    # n         | absolute value of the source number (integer/float/decimal).
    # i         | integer digits of n.
    # v         | number of visible fractional digits in n, with trailing zeros.
    # w         | number of visible fractional digits in n, without trailing zeros.
    # f         | visible fractional digits in n, with trailing zeros.
    # t         | visible fractional digits in n, without trailing zeros.
    defp get_suffix(unquote(lang), n, i, v, w, f, t) do
      e = 0
      _ = {n, i, v, w, f, t, e}
      unquote(AST.rules_to_cond(rules))
    end
  end

  defp get_suffix(lang, _n, _i, _v, _w, _f, _t) do
    Logger.warning("No plural rules found for #{lang} - returning `other`")
    "other"
  end

  def get_suffix(lang, count)
  def get_suffix(_lang, nil), do: "other"
  def get_suffix(lang, count) when is_binary(count), do: get_suffix(lang, Decimal.new(count))
  def get_suffix(lang, count) when is_float(count), do: get_suffix(lang, Decimal.new(Float.to_string(count)))
  def get_suffix(lang, count) when is_integer(count), do: get_suffix(lang, abs(count), abs(count), 0, 0, 0, 0)

  def get_suffix(lang, count) do
    n = Decimal.abs(count)
    i = Decimal.round(count, 0, :floor) |> Decimal.to_integer()
    v = abs(n.exp)

    f =
      n
      |> Decimal.sub(i)
      |> Decimal.mult(Decimal.new(Integer.pow(10, v)))
      |> Decimal.round(0, :floor)
      |> Decimal.to_integer()

    t =
      Integer.to_string(f)
      |> String.trim_trailing("0")
      |> case do
        "" -> 0
        other -> Decimal.new(other) |> Decimal.to_integer()
      end

    w = Integer.to_string(f) |> String.trim_trailing("0") |> String.length()

    n = Decimal.to_float(n)

    get_suffix(lang, n, i, v, f, t, w)
  end
end
