defmodule Idiom.Pluralizer.Util do
  def parse_rules({lang, rules}) do
    parsed_rules =
      Enum.map(rules, fn {"pluralRule-count-" <> suffix, rule} ->
        {:ok, ast} = parse(rule)
        {suffix, ast}
      end)
      |> Enum.sort(&suffix_sorter/2)

    {lang, parsed_rules}
  end

  defp suffix_sorter({"zero", _}, _), do: true
  defp suffix_sorter({"one", _}, {other, _}) when other in ["two", "few", "many", "other"], do: true
  defp suffix_sorter({"two", _}, {other, _}) when other in ["few", "many", "other"], do: true
  defp suffix_sorter({"few", _}, {other, _}) when other in ["many", "other"], do: true
  defp suffix_sorter({"many", _}, {other, _}) when other in ["other"], do: true
  defp suffix_sorter(_, _), do: false

  defp parse([]), do: {:ok, []}
  defp parse(tokens) when is_list(tokens), do: :pluralizer_parser.parse(tokens)

  defp parse(definition) when is_binary(definition) do
    {:ok, tokens, _} =
      definition
      |> String.to_charlist()
      |> :pluralizer_lexer.string()

    parse(tokens)
  end

  def rules_to_cond(rules) do
    clauses =
      Enum.map(rules, fn {suffix, ast} ->
        rule_to_clause(ast, suffix)
      end)
      |> Enum.sort(fn {:->, [], [[ast], _suffix]}, _ -> not (ast == true) end)

    {:cond, [], [[do: clauses]]}
  end

  defp rule_to_clause(nil, suffix), do: {:->, [], [[true], suffix]}
  defp rule_to_clause(ast, suffix), do: {:->, [], [[ast], suffix]}

  def in?(%Decimal{} = number, range) do
    Decimal.to_float(number) |> in?(range)
  end

  def in?(number, range) when is_integer(number) do
    number in range
  end

  def in?(number, range) when is_float(number) do
    trunc(number) in range
  end

  def mod(dividend, divisor) when is_float(dividend) and is_number(divisor) do
    dividend - Float.floor(dividend / divisor) * divisor
  end

  def mod(dividend, divisor) when is_integer(dividend) and is_integer(divisor) do
    modulo =
      dividend
      |> Integer.floor_div(divisor)
      |> Kernel.*(divisor)

    dividend - modulo
  end

  def mod(dividend, divisor) when is_integer(dividend) and is_number(divisor) do
    modulo =
      dividend
      |> Kernel./(divisor)
      |> Float.floor()
      |> Kernel.*(divisor)

    dividend - modulo
  end

  def mod(%Decimal{} = dividend, %Decimal{} = divisor) do
    modulo =
      dividend
      |> Decimal.div(divisor)
      |> Decimal.round(0, :floor)
      |> Decimal.mult(divisor)

    Decimal.sub(dividend, modulo)
  end

  def mod(%Decimal{} = dividend, divisor) when is_integer(divisor), do: mod(dividend, Decimal.new(divisor))
end
