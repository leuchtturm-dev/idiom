defmodule Idiom.PluralGetSuffixTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Idiom.Plural

  describe "when count is nil" do
    test "returns `other` for any language, and plural type" do
      assert Plural.get_suffix("en", nil) == "other"
      assert Plural.get_suffix("de", nil) == "other"
      assert Plural.get_suffix("ar", nil) == "other"
      assert Plural.get_suffix("cy", nil) == "other"
      assert Plural.get_suffix("en", nil, type: :ordinal) == "other"
      assert Plural.get_suffix("de", nil, type: :ordinal) == "other"
      assert Plural.get_suffix("ar", nil, type: :ordinal) == "other"
      assert Plural.get_suffix("cy", nil, type: :ordinal) == "other"
    end
  end

  describe "when language is not supported" do
    @tag capture_log: true
    test "returns `other` for any count and plural type" do
      Plural.get_suffix("foo", 0)
      Plural.get_suffix("foo", 1)
      Plural.get_suffix("foo", 500)
      Plural.get_suffix("foo", 0, type: :ordinal)
      Plural.get_suffix("foo", 1, type: :ordinal)
      Plural.get_suffix("foo", 500, type: :ordinal)
    end

    test "logs a warning that language is unsuppored" do
      assert capture_log(fn ->
               Plural.get_suffix("foo", 0)
             end) =~ "No plural rules found for foo"
    end
  end

  describe "when count is an integer" do
    tests = [
      %{lang: "en", count: 0, opts: [], expected: "other"},
      %{lang: "en", count: 1, opts: [], expected: "one"},
      %{lang: "de", count: 1, opts: [], expected: "one"},
      %{lang: "ar", count: 0, opts: [], expected: "zero"},
      %{lang: "ar", count: 1, opts: [], expected: "one"},
      %{lang: "ar", count: 2, opts: [], expected: "two"},
      %{lang: "ar", count: 3, opts: [type: :cardinal], expected: "few"},
      %{lang: "ar", count: 50, opts: [type: :cardinal], expected: "many"},
      %{lang: "ar", count: 500, opts: [type: :cardinal], expected: "other"},
      %{lang: "cy", count: 3, opts: [type: :cardinal], expected: "few"},
      %{lang: "cy", count: 6, opts: [type: :cardinal], expected: "many"},
      %{lang: "en", count: 0, opts: [type: :ordinal], expected: "other"},
      %{lang: "en", count: 1, opts: [type: :ordinal], expected: "one"},
      %{lang: "en", count: 2, opts: [type: :ordinal], expected: "two"},
      %{lang: "en", count: 3, opts: [type: :ordinal], expected: "few"},
      %{lang: "de", count: 1, opts: [type: :ordinal], expected: "other"},
      %{lang: "ar", count: 0, opts: [type: :ordinal], expected: "other"}
    ]

    for %{lang: lang, count: count, opts: opts, expected: expected} <- tests do
      test "returns the correct suffix for lang #{lang}, count #{count} and opts #{inspect(opts)}" do
        assert Plural.get_suffix(unquote(lang), unquote(count), unquote(opts)) ==
                 unquote(expected)
      end
    end
  end

  describe "when count is a float" do
    tests = [
      %{lang: "en", count: 0.5, expected: "other"},
      %{lang: "en", count: 1.0, expected: "other"},
      %{lang: "de", count: 1.5, expected: "other"},
      %{lang: "ar", count: 0.5, expected: "other"},
      %{lang: "ar", count: 1.0, expected: "one"},
      %{lang: "ar", count: 2.6, expected: "other"},
      %{lang: "ar", count: 3.1, expected: "few"},
      %{lang: "ar", count: 50.0, expected: "many"},
      %{lang: "ar", count: 500.0, expected: "other"},
      %{lang: "cy", count: 3.1, expected: "other"},
      %{lang: "cy", count: 6.5, expected: "other"}
    ]

    for %{lang: lang, count: count, expected: expected} <- tests do
      test "returns the correct suffix for lang #{lang} and count #{count}" do
        assert Plural.get_suffix(unquote(lang), unquote(count)) == unquote(expected)
      end
    end
  end

  describe "when count is a Decimal" do
    tests =
      Enum.map(
        [
          %{lang: "en", count: Decimal.new(0), expected: "other"},
          %{lang: "en", count: Decimal.new(1), expected: "one"},
          %{lang: "de", count: Decimal.new(1), expected: "one"},
          %{lang: "ar", count: Decimal.new(0), expected: "zero"},
          %{lang: "ar", count: Decimal.new(1), expected: "one"},
          %{lang: "ar", count: Decimal.new("2"), expected: "two"},
          %{lang: "ar", count: Decimal.new("3"), expected: "few"},
          %{lang: "ar", count: Decimal.new("50"), expected: "many"},
          %{lang: "ar", count: Decimal.new("500.0"), expected: "other"},
          %{lang: "cy", count: Decimal.new("3.1"), expected: "other"},
          %{lang: "cy", count: Decimal.new("6.5"), expected: "other"}
        ],
        fn test -> Map.update!(test, :count, &Macro.escape/1) end
      )

    for %{lang: lang, count: count, expected: expected} <- tests do
      test "returns the correct suffix for lang #{lang} and count #{inspect(count)}" do
        assert Plural.get_suffix(unquote(lang), unquote(count)) == unquote(expected)
      end
    end
  end
end
