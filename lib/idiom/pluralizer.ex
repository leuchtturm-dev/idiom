defmodule Idiom.Pluralizer do
  alias Idiom.Languages
  alias Idiom.Pluralizer.Compiler

  import Idiom.Pluralizer.Util

  @rules [:code.priv_dir(Mix.Project.config()[:app]), "/idiom"]
         |> :erlang.iolist_to_binary()
         |> Path.join("/plural_rules.json")
         |> File.read!()
         |> Jason.decode!()
         |> Map.get("cardinal")
         |> Enum.map(&Compiler.normalize_locale_rules/1)
         |> Map.new()

  for {lang, conditions} <- @rules do
    defp do_get_plural(unquote(lang), n, i, v, w, f, t, e) do
      _ = {n, i, v, w, f, t, e}
      unquote(Compiler.rules_to_condition_statement(conditions, __MODULE__))
    end
  end

  def get_plural(lang, count) when is_binary(count), do: get_plural(lang, Decimal.new(count))
  def get_plural(lang, count) when is_integer(count), do: do_get_plural(lang, abs(count), abs(count), 0, 0, 0, 0, 0)
end
