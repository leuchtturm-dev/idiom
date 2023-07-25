defmodule Idiom.PluralPreprocess.ParseRulesTest do
  use ExUnit.Case, async: true
  alias Idiom.PluralPreprocess

  # NOTE:
  # This is not testing public API, as these functions should never be used by an end user.
  # Instead, they serve as regression test for the lexer, parser and AST generators.

  tests = [
    %{rule: [{"pluralRule-count-one", "n = 1"}], expected_ast: quote(do: {:cond, [], [[do: [{:->, [], [[{:==, [], [{:n, [], nil}, 1]}], "one"]}]]]})},
    %{
      rule: [{"pluralRule-count-few", "n % 100 = 3..10 "}],
      expected_ast: quote(do: {:cond, [], [[do: [{:->, [], [[{:in?, [], [{:mod, [], [{:n, [], nil}, 100]}, {:.., [], [3, 10]}]}], "few"]}]]]})
    },
    %{
      rule: [{"pluralRule-count-one", "v = 0 and i % 10 = 1 and i % 100 != 11 or f % 10 = 1 and f % 100 != 11"}],
      expected_ast:
        quote(
          do: {
            :cond,
            [],
            [
              [
                do: [
                  {:->, [],
                   [
                     [
                       {:or, [],
                        [
                          {:and, [],
                           [
                             {:==, [], [{:v, [], nil}, 0]},
                             {:and, [], [{:==, [], [{:mod, [], [{:i, [], nil}, 10]}, 1]}, {:!, [], [{:==, [], [{:mod, [], [{:i, [], nil}, 100]}, 11]}]}]}
                           ]},
                          {:and, [], [{:==, [], [{:mod, [], [{:f, [], nil}, 10]}, 1]}, {:!, [], [{:==, [], [{:mod, [], [{:f, [], nil}, 100]}, 11]}]}]}
                        ]}
                     ],
                     "one"
                   ]}
                ]
              ]
            ]
          }
        )
    }
  ]

  for %{rule: rule, expected_ast: expected_ast} <- tests do
    test "generates the correct ast for rule #{inspect(rule)}" do
      assert unquote(expected_ast) = PluralPreprocess.parse_rules(unquote(rule))
    end
  end
end
