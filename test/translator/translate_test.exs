defmodule Idiom.Translator.TranslateTest do
  use ExUnit.Case, async: true

  alias Idiom.Cache
  alias Idiom.Translator

  @cache_table_name :idiom_translator_translate_test
  @data %{
    en: %{
      translation: %{
        "test" => "test_en",
        "key.with.dot" => "dot",
        "deep" => %{
          test: "deep_en"
        }
      }
    },
    de: %{
      translation: %{
        test: "test_de"
      }
    }
  }

  setup do
    Cache.init(@data, @cache_table_name)
  end

  # %{key: "translation:test", %{lng: "fr"}, expected: "test_en"},
  # %{key: "translation:test", %{lng: "en-US"}, expected: "test_en"},
  # %{key: "translation.test", %{lng: "en-US", ns_separator: "."}, expected: "test_en"},
  # %{key: "translation.deep.test", %{lng: "en-US", ns_separator: "."}, expected: "deep_en"},
  # %{key: "deep.test", %{lng: "en-US", ns_separator: "."}, expected: "deep_en"}
  #
  @tests [
    %{key: "test", opts: [], expected: "test_en"},
    %{key: "translation:test", opts: [], expected: "test_en"},
    %{key: "key.with.dot", opts: [], expected: "dot"},
    %{key: "deep.test", opts: [], expected: "deep_en"},
    %{key: "translation:deep.test", opts: [], expected: "deep_en"},
    %{key: "test", opts: [language: "en"], expected: "test_en"},
    %{key: "test", opts: [language: "de"], expected: "test_de"},
  ]

  for %{key: key, opts: opts, expected: expected} <- @tests do
    test "correctly translates `#{key}` with opts `#{inspect(opts)}`" do
      opts = unquote(opts) |> Keyword.put(:cache_table_name, @cache_table_name)
      assert Translator.translate(unquote(key), opts) == unquote(expected)
    end
  end
end
