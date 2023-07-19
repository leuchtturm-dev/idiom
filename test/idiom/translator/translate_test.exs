defmodule Idiom.Translator.TranslateTest do
  use ExUnit.Case, async: true
  import Idiom
  alias Idiom.Cache

  @cache_table_name :idiom_translator_translate_test
  @data %{
    "en" => %{
      "translations" => %{
        "test" => "test_en",
        "key.with.dot" => "dot",
        "deep" => %{
          "test" => "deep_en"
        },
        "natural language key" => "natural language key",
        "natural language key with dot. it continues" => "natural language key with dot. it continues"
      }
    },
    "en-US" => %{
      "translations" => %{
        "test.locale" => "en-US"
      }
    },
    "de" => %{
      "translations" => %{
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
    %{lang: "en", key: "test", expected: "test_en"},
    # With domain
    %{lang: "en", key: "translation:test", expected: "test_en"},
    # With dot
    %{lang: "en", key: "key.with.dot", expected: "dot"},
    # With nested source data
    %{lang: "en", key: "deep.test", expected: "deep_en"},
    # With domain and nested source data
    %{lang: "en", key: "translation:deep.test", expected: "deep_en"},
    # With natural language key
    %{lang: "en", key: "natural language key", expected: "natural language key"},
    # With natural language key containing dot
    %{lang: "en", key: "natural language key with dot. it continues", expected: "natural language key with dot. it continues"},
    # With other language
    %{lang: "de", key: "test", expected: "test_de"},
    # With fallback language
    %{lang: "de", key: "natural language key with dot. it continues", opts: [fallback: "en"], expected: "natural language key with dot. it continues"},
    # With domain and other language
    %{lang: "de", key: "login:Sign in", expected: "Registrieren"},
    # With locale
    %{lang: "en-US", key: "test.locale", expected: "en-US"},
    # With locale falling back to language
    %{lang: "en-US", key: "test", expected: "test_en"}
  ]

  for %{key: key, lang: lang, opts: opts, expected: expected} <- @tests do
    test "correctly translates `#{key}` to `#{lang}`" do
      opts = unquote(opts) |> Keyword.put(:cache_table_name, @cache_table_name) |> Keyword.put(:to, unquote(lang))
      assert translate(unquote(key), opts) == unquote(expected)
    end
  end

  test "respects `lang` in Process" do
    Process.put(:lang, "de")
    assert translate("login:Sign in", cache_table_name: @cache_table_name) == "Registrieren"
  end
end
