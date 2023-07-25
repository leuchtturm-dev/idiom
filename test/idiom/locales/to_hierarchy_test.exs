defmodule Idiom.LocalesToHierarchyTest do
  use ExUnit.Case, async: true
  alias Idiom.Locales

  tests = [
    # With language
    %{code: "en", opts: [], expected: ["en"]},
    %{code: "de", opts: [], expected: ["de"]},
    # With language and region
    %{code: "en-US", opts: [], expected: ["en-US", "en"]},
    %{code: "de-DE", opts: [], expected: ["de-DE", "de"]},
    # With language and script
    %{code: "az-Cyrl", opts: [], expected: ["az-Cyrl", "az"]},
    %{code: "zh-Hant", opts: [], expected: ["zh-Hant", "zh"]},
    # With language, script and region
    %{code: "az-Cyrl-AZ", opts: [], expected: ["az-Cyrl-AZ", "az-Cyrl", "az"]},
    %{code: "zh-Hant-MO", opts: [], expected: ["zh-Hant-MO", "zh-Hant", "zh"]},
    # With language and fallback
    %{code: "en", opts: [fallback: "en"], expected: ["en"]},
    %{code: "de", opts: [fallback: "en"], expected: ["de", "en"]},
    # With language and multiple fallbacks
    %{code: "en", opts: [fallback: ["fr", "en"]], expected: ["en", "fr"]},
    %{code: "de", opts: [fallback: ["fr", "en"]], expected: ["de", "fr", "en"]},
    # With locale and fallback
    %{code: "de-CH", opts: [fallback: ["fr", "en"]], expected: ["de-CH", "de", "fr", "en"]},
    # With script and multiple fallbacks
    %{code: "az-Cyrl-AZ", opts: [fallback: ["fr", "en"]], expected: ["az-Cyrl-AZ", "az-Cyrl", "az", "fr", "en"]},
    %{code: "zh-Hant-MO", opts: [fallback: ["fr", "en"]], expected: ["zh-Hant-MO", "zh-Hant", "zh", "fr", "en"]}
  ]

  for %{code: lang, opts: opts, expected: expected} <- tests do
    test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
      assert Locales.get_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
    end
  end
end
