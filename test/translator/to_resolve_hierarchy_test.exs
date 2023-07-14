defmodule Translator.ToResolveHierarchyTest do
  use ExUnit.Case, async: true

  alias Idiom.Translator

  @tests [
    %{lang: "en", opts: [fallback_lang: "en"], expected: ["en"]},
    %{lang: "en-US", opts: [fallback_lang: "en"], expected: ["en-US", "en"]},
    %{lang: "de", opts: [fallback_lang: "en"], expected: ["de", "en"]},
    %{lang: "de", opts: [fallback_lang: "fr"], expected: ["de", "fr"]},
    # %{lang: "de", opts: [fallback_lang: "en"], expected: ["de", "fr", "en"]},
    # %{lang: "de", opts: [fallback_lang: "fr"], expected: ["de", "fr"]},
    # %{lang: "de-CH", opts: [fallback_lang: "en"], expected: ["de-CH", "de", "en"]},
    # %{lang: "nb-NO", opts: [fallback_lang: "en"], expected: ["nb-NO", "nb", "en"]},
    # %{
    #   lang: ["zh-Hant-MO"],
    #   opts: [fallback_lang: "en"],
    #   expected: ["zh-Hant-MO", "zh-Hant", "zh", "en"]
    # },
    # %{
    #   lang: ["de-x-custom1"],
    #   opts: [fallback_lang: "en"],
    #   expected: ["de-x-custom1", "de", "en"]
    # },
    # %{
    #   lang: ["de-DE-x-custom1"],
    #   opts: [fallback_lang: "en"],
    #   expected: ["de-DE-x-custom1", "de", "en"]
    # }
  ]

  for %{lang: lang, opts: opts, expected: expected} <- @tests do
    test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
      assert Translator.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
    end
  end
end
