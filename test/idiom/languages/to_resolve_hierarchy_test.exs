defmodule Idiom.Languages.ToResolveHierarchyTest do
  use ExUnit.Case, async: true

  alias Idiom.Languages

  describe "with language" do
    tests = [
      %{code: "en", opts: [fallback: "en"], expected: ["en"]},
      %{code: "de", opts: [fallback: "en"], expected: ["de", "en"]}
    ]

    for %{code: lang, opts: opts, expected: expected} <- tests do
      test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
        assert Languages.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
      end
    end
  end

  describe "with locale" do
    tests = [
      %{code: "en-US", opts: [fallback: "en"], expected: ["en-US", "en"]},
      %{code: "de-DE", opts: [fallback: "en"], expected: ["de-DE", "de", "en"]}
    ]

    for %{code: lang, opts: opts, expected: expected} <- tests do
      test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
        assert Languages.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
      end
    end
  end

  describe "with script" do
    tests = [
      %{code: "az-Cyrl", opts: [fallback: "en"], expected: ["az-Cyrl", "az", "en"]},
      %{code: "zh-Hant", opts: [fallback: "en"], expected: ["zh-Hant", "zh", "en"]}
    ]

    for %{code: lang, opts: opts, expected: expected} <- tests do
      test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
        assert Languages.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
      end
    end
  end

  describe "with script and locale" do
    tests = [
      %{code: "az-Cyrl-AZ", opts: [fallback: "en"], expected: ["az-Cyrl-AZ", "az-Cyrl", "az", "en"]},
      %{code: "zh-Hant-MO", opts: [fallback: "en"], expected: ["zh-Hant-MO", "zh-Hant", "zh", "en"]}
    ]

    for %{code: lang, opts: opts, expected: expected} <- tests do
      test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
        assert Languages.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
      end
    end
  end

  describe "with language and array as fallback" do
    tests = [
      %{code: "en", opts: [fallback: ["fr", "en"]], expected: ["en", "fr"]},
      %{code: "de", opts: [fallback: ["fr", "en"]], expected: ["de", "fr", "en"]}
    ]

    for %{code: lang, opts: opts, expected: expected} <- tests do
      test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
        assert Languages.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
      end
    end
  end

  describe "with locale and array as fallback" do
    tests = [
      %{code: "de-CH", opts: [fallback: ["fr", "en"]], expected: ["de-CH", "de", "fr", "en"]}
    ]

    for %{code: lang, opts: opts, expected: expected} <- tests do
      test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
        assert Languages.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
      end
    end
  end

  describe "with script and array as fallback" do
    tests = [
      %{code: "az-Cyrl-AZ", opts: [fallback: ["fr", "en"]], expected: ["az-Cyrl-AZ", "az-Cyrl", "az", "fr", "en"]},
      %{code: "zh-Hant-MO", opts: [fallback: ["fr", "en"]], expected: ["zh-Hant-MO", "zh-Hant", "zh", "fr", "en"]}
    ]

    for %{code: lang, opts: opts, expected: expected} <- tests do
      test "correctly creates resolve hierarchy for lang `#{lang}` with opts `#{inspect(opts)}`" do
        assert Languages.to_resolve_hierarchy(unquote(lang), unquote(opts)) == unquote(expected)
      end
    end
  end
end
