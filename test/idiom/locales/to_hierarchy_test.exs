defmodule Idiom.LocalesToHierarchyTest do
  use ExUnit.Case, async: true

  alias Idiom.Locales

  tests = [
    # With localeuage
    %{locale: "en", opts: [], expected: ["en"]},
    %{locale: "de", opts: [], expected: ["de"]},
    # With localeuage and region
    %{locale: "en-US", opts: [], expected: ["en-US", "en"]},
    %{locale: "de-DE", opts: [], expected: ["de-DE", "de"]},
    # With localeuage and script
    %{locale: "az-Cyrl", opts: [], expected: ["az-Cyrl", "az"]},
    %{locale: "zh-Hant", opts: [], expected: ["zh-Hant", "zh"]},
    # With localeuage, script and region
    %{locale: "az-Cyrl-AZ", opts: [], expected: ["az-Cyrl-AZ", "az-Cyrl", "az"]},
    %{locale: "zh-Hant-MO", opts: [], expected: ["zh-Hant-MO", "zh-Hant", "zh"]},
    # With localeuage and fallback
    %{locale: "en", opts: [fallback: "en"], expected: ["en"]},
    %{locale: "de", opts: [fallback: "en"], expected: ["de", "en"]},
    # With localeuage and multiple fallbacks
    %{locale: "en", opts: [fallback: ["fr", "en"]], expected: ["en", "fr"]},
    %{locale: "de", opts: [fallback: ["fr", "en"]], expected: ["de", "fr", "en"]},
    # With locale and fallback
    %{
      locale: "de-CH",
      opts: [fallback: ["fr", "en"]],
      expected: ["de-CH", "de", "fr", "en"]
    },
    # With script and multiple fallbacks
    %{
      locale: "az-Cyrl-AZ",
      opts: [fallback: ["fr", "en"]],
      expected: ["az-Cyrl-AZ", "az-Cyrl", "az", "fr", "en"]
    },
    %{
      locale: "zh-Hant-MO",
      opts: [fallback: ["fr", "en"]],
      expected: ["zh-Hant-MO", "zh-Hant", "zh", "fr", "en"]
    }
  ]

  for %{locale: locale, opts: opts, expected: expected} <- tests do
    test "correctly creates resolve hierarchy for locale `#{locale}` with opts `#{inspect(opts)}`" do
      assert Locales.get_hierarchy(unquote(locale), unquote(opts)) == unquote(expected)
    end
  end
end
