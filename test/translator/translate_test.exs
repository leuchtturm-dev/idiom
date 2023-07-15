defmodule Idiom.Translator.TranslateTest do
  use ExUnit.Case, async: true

  alias Idiom.Cache
  alias Idiom.Translator

  @cache_table_name :idiom_translator_translate_test
  @data %{
    "en" => %{
      "translation" => %{
        "test" => "test_en",
        "key.with.dot" => "dot",
        "deep" => %{
          "test" => "deep_en"
        },
        "natural language key" => "natural language key",
        "natural language key with dot. it continues" => "natural language key with dot. it continues"
      }
    },
    "de" => %{
      "translation" => %{
        "test" => "test_de"
      },
      "login" => %{
        "Sign in" => "Registrieren"
      }
    }
  }

  setup do
    Cache.init(@data, @cache_table_name)
  end

  @tests [
    # Basic
    %{key: "test", opts: [to: "en"], expected: "test_en"},
    # With domain
    %{key: "translation:test", opts: [to: "en"], expected: "test_en"},
    # With dot
    %{key: "key.with.dot", opts: [to: "en"], expected: "dot"},
    # With nested source data
    %{key: "deep.test", opts: [to: "en"], expected: "deep_en"},
    # With domain and nested source data
    %{key: "translation:deep.test", opts: [to: "en"], expected: "deep_en"},
    # With natural language key
    %{key: "natural language key", opts: [to: "en"], expected: "natural language key"},
    # With natural language key containing dot
    %{key: "natural language key with dot. it continues", opts: [to: "en"], expected: "natural language key with dot. it continues"},
    # With other language
    %{key: "test", opts: [to: "de"], expected: "test_de"},
    # With fallback language
    %{key: "natural language key with dot. it continues", opts: [to: "de", fallback_lang: "en"], expected: "natural language key with dot. it continues"},
    # With domain and other language
    %{key: "login:Sign in", opts: [to: "de"], expected: "Registrieren"}
  ]

  for %{key: key, opts: opts, expected: expected} <- @tests do
    test "correctly translates `#{key}` with opts `#{inspect(opts)}`" do
      opts = unquote(opts) |> Keyword.put(:cache_table_name, @cache_table_name)
      assert Translator.translate(unquote(key), opts) == unquote(expected)
    end
  end
end
