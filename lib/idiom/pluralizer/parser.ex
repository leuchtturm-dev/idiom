defmodule Idiom.Pluralizer.Parser do
  def parse_rules({lang, rules}) do
    parsed_rules =
      Enum.map(rules, fn {"pluralRule-count-" <> suffix, rule} ->
        {:ok, ast} = parse(rule)
        {suffix, ast}
      end)
    |> Enum.sort(&plural_sorter/2)

    {lang, parsed_rules}
  end

  defp plural_sorter({"zero", _}, _), do: true
  defp plural_sorter({"one", _}, {other, _}) when other in ["two", "few", "many", "other"], do: true
  defp plural_sorter({"two", _}, {other, _}) when other in ["few", "many", "other"], do: true
  defp plural_sorter({"few", _}, {other, _}) when other in ["many", "other"], do: true
  defp plural_sorter({"many", _}, {other, _}) when other in ["other"], do: true
  defp plural_sorter(_, _), do: false

  defp parse([]), do: {:ok, []}
  defp parse(tokens) when is_list(tokens), do: :pluralizer_parser.parse(tokens)

  defp parse(definition) when is_binary(definition) do
    {:ok, tokens, _} =
      definition
      |> String.to_charlist()
      |> :pluralizer_lexer.string()

    parse(tokens)
  end
end
