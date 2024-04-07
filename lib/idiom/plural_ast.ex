defmodule Idiom.PluralAST do
  @moduledoc """
  Preprocessor for language-specific pluralization rules.

  Idiom uses Unicode CLDR plural rules, which they provide for download as a JSON file. This is stored in our `priv` directory.
  The `Plural` and `PluralAST` modules use these definitions to generate Elixir ASTs representing a `cond` statement for each language, which are then
  used at compile-time to generate functions.

  This module builds on a lexer and parser inside the `src/` directory to generate the ASTs.
  """

  @doc false
  def fetch_rules(type) do
    "priv/idiom/plurals-#{type}.json"
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "plurals-type-#{type}"])
  end

  @doc false
  def get_suffixes(rules) do
    Map.new(rules, fn {lang, rules} ->
      suffixes =
        rules
        |> Enum.reduce([], fn {"pluralRule-count-" <> suffix, _rule}, acc -> [suffix | acc] end)
        |> Enum.sort(&suffix_sorter/2)

      {lang, suffixes}
    end)
  end

  @doc false
  def parse_rules(rules) do
    rules
    |> Enum.map(fn {"pluralRule-count-" <> suffix, rule} ->
      {:ok, ast} = parse(rule)
      {suffix, ast}
    end)
    |> Enum.sort(fn {first, _}, {second, _} -> suffix_sorter(first, second) end)
    |> rules_to_cond()
  end

  defp suffix_sorter("zero", _), do: true

  defp suffix_sorter("one", other) when other in ["two", "few", "many", "other"], do: true

  defp suffix_sorter("two", other) when other in ["few", "many", "other"], do: true

  defp suffix_sorter("few", other) when other in ["many", "other"], do: true
  defp suffix_sorter("many", other) when other in ["other"], do: true
  defp suffix_sorter(_, _), do: false

  defp parse([]), do: {:ok, []}
  defp parse(tokens) when is_list(tokens), do: :plural_parser.parse(tokens)

  defp parse(definition) when is_binary(definition) do
    {:ok, tokens, _} =
      definition
      |> String.to_charlist()
      |> :plural_lexer.string()

    parse(tokens)
  end

  defp rules_to_cond(rules) do
    clauses =
      Enum.map(rules, fn {suffix, ast} ->
        rule_to_clause(ast, suffix)
      end)

    {:cond, [], [[do: clauses]]}
  end

  defp rule_to_clause(nil, suffix), do: {:->, [], [[true], suffix]}
  defp rule_to_clause(ast, suffix), do: {:->, [], [[ast], suffix]}
end
