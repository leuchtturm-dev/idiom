defmodule Idiom.Pluralizer.Compiler do
  @ast %{
    foo:
      {:cond, [],
       [
         [
           do: [
             {:->, [],
              [
                [
                  {:==, [], [{:n, [], nil}, 10]}
                ],
                1
              ]},
             {:->, [],
              [
                [
                  {:>, [], [{:n, [], nil}, 1]}
                ],
                2
              ]},
             {:->, [], [[true], 3]}
           ]
         ]
       ]},
    bar: {:cond, [], [[do: [{:->, [], [[true], 10]}]]]}
  }

  def ast, do: @ast

  def normalize_locale_rules({locale, rules}) do
    sorted_rules =
      Enum.map(rules, fn {"pluralRule-count-" <> category, rule} ->
        {:ok, definition} = parse(rule)
        {String.to_atom(category), definition}
      end)
      |> Enum.sort(&plural_sorter/2)

    {String.to_atom(locale), sorted_rules}
  end

  defp plural_sorter({:zero, _}, _), do: true
  defp plural_sorter({:one, _}, {other, _}) when other in [:two, :few, :many, :other], do: true
  defp plural_sorter({:two, _}, {other, _}) when other in [:few, :many, :other], do: true
  defp plural_sorter({:few, _}, {other, _}) when other in [:many, :other], do: true
  defp plural_sorter({:many, _}, {other, _}) when other in [:other], do: true
  defp plural_sorter(_, _), do: false

  def rules_to_condition_statement(rules, module) do
    branches =
      Enum.map(rules, fn {category, definition} ->
        {new_ast, _} = set_operand_module(definition[:rule], module)
        rule_to_cond_branch(new_ast, category)
      end)

    {:cond, [], [[do: move_true_branch_to_end(branches)]]}
  end

  # We can't assume the order of branches and we need the
  # `true` branch at the end since it will always match
  # and hence potentially shadow other branches
  defp move_true_branch_to_end(branches) do
    Enum.sort(branches, fn {:->, [], [[ast], _category]}, _other_branch ->
      not (ast == true)
    end)
  end

  # Walk the AST and replace the variable context to that of the calling
  # module
  defp set_operand_module(ast, module) do
    Macro.prewalk(ast, [], fn expr, acc ->
      new_expr =
        case expr do
          {var, [], Elixir} ->
            {var, [], nil}

          # {var, [], module}
          {:mod, _context, [operand, value]} ->
            {:mod, [context: Elixir, import: Elixir.Cldr.Math], [operand, value]}

          {:within, _context, [operand, range]} ->
            {:within, [context: Elixir, import: Elixir.Cldr.Math], [operand, range]}

          _ ->
            expr
        end

      {new_expr, acc}
    end)
  end

  # Transform the rule AST into a branch of a `cond` statement
  defp rule_to_cond_branch(nil, category) do
    {:->, [], [[true], category]}
  end

  defp rule_to_cond_branch(rule_ast, category) do
    {:->, [], [[rule_ast], category]}
  end

  defp parse(tokens) when is_list(tokens) do
    :plural_rules_parser.parse(tokens)
  end

  defp parse(definition) when is_binary(definition) do
    {:ok, tokens, _} =
      definition
      |> String.to_charlist()
      |> :plural_rules_lexer.string()

    IO.inspect(tokens)

    parse(tokens)
  end
end
