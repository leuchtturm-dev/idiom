defmodule Idiom.Pluralizer.Parser do
  def parse_rules({lang, rules}) do
    parsed_rules =
      Enum.map(rules, fn {"pluralRule-count-" <> suffix, rule} ->
        {:ok, ast} = parse(rule)

        {suffix, ast}
      end)

    {lang, parsed_rules}
  end

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
