defmodule Idiom.PluralPreprocess do
  @moduledoc """
  Preprocessor for language-specific pluralization rules.
  """

  @doc """
  Parses and sorts language-specific pluralization rules.

  This function takes as input a tuple, where the first element is a string representing the language identifier (e.g., `"en"` for English), and the second element is a list of tuples. Each tuple in the list represents a pluralization rule, with the first element being a string that specifies the rule's category (e.g., `"pluralRule-count-one"`), and the second element being a string that specifies the rule itself.

  The function parses these rules into abstract syntax trees (ASTs), sorts them according to a predefined order ("zero", "one", "two", "few", "many", "other"), and returns a tuple where the first element is the language identifier and the second element is the AST of a `cond` statement with a clause for each rule and suffix.

  ## Examples

    iex> Idiom.PluralPreprocess.parse_rules({"en", [{"pluralRule-count-one", "n = 1"}]})
    {"en", {:cond, [], [[do: [{:->, [], [[{:==, [], [{:n, [], nil}, 1]}], "one"]}]]]}}
  """
  def parse_rules({lang, rules}) do
    parsed_rules =
      Enum.map(rules, fn {"pluralRule-count-" <> suffix, rule} ->
        {:ok, ast} = parse(rule)
        {suffix, ast}
      end)
      |> Enum.sort(&suffix_sorter/2)
      |> rules_to_cond()

    {lang, parsed_rules}
  end

  defp suffix_sorter({"zero", _}, _), do: true
  defp suffix_sorter({"one", _}, {other, _}) when other in ["two", "few", "many", "other"], do: true
  defp suffix_sorter({"two", _}, {other, _}) when other in ["few", "many", "other"], do: true
  defp suffix_sorter({"few", _}, {other, _}) when other in ["many", "other"], do: true
  defp suffix_sorter({"many", _}, {other, _}) when other in ["other"], do: true
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
    clauses = Enum.map(rules, fn {suffix, ast} -> rule_to_clause(ast, suffix) end)

    {:cond, [], [[do: clauses]]}
  end

  defp rule_to_clause(nil, suffix), do: {:->, [], [[true], suffix]}
  defp rule_to_clause(ast, suffix), do: {:->, [], [[ast], suffix]}
end
