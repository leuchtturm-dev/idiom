defmodule Idiom.Pluralizer.AST do
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
end
