defmodule I18ex.Translator.TranslateTest do
  use ExUnit.Case, async: true

  alias I18ex.Translator

  @data %{
    en: %{
      default: %{
        test: "test_en",
        deep: %{
          test: "deep_en"
        }
      }
    },
    de: %{
      default: %{
        test: "test_de"
      }
    }
  }

  setup do
    {:ok, pid} =
      I18ex.Backends.Memory.start_link(
        name: :translate_test_backend,
        data: @data
      )

    %{backend: pid}
  end

  @tests [
    %{key: "test", opts: [], expected: "test_en"},
    %{key: "default:test", opts: [], expected: "test_en"},
    %{key: "test", opts: [language: "en"], expected: "test_en"},
    %{key: "test", opts: [language: "de"], expected: "test_de"},
    # %{key: "translation:test", %{lng: "de"}, expected: "test_de"},
    # %{key: "translation:test", %{lng: "fr"}, expected: "test_en"},
    # %{key: "translation:test", %{lng: "en-US"}, expected: "test_en"},
    # %{key: "translation.test", %{lng: "en-US", ns_separator: "."}, expected: "test_en"},
    # %{key: "translation.deep.test", %{lng: "en-US", ns_separator: "."}, expected: "deep_en"},
    # %{key: "deep.test", %{lng: "en-US", ns_separator: "."}, expected: "deep_en"}
  ]

  for %{key: key, opts: opts, expected: expected} <- @tests do
    test "correctly translates #{key} with opts #{inspect(opts)}", %{backend: backend} do
      assert Translator.translate(backend, unquote(key), unquote(opts)) == unquote(expected)
    end
  end
end
