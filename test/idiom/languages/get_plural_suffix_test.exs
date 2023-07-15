defmodule Idiom.Languages.GetPluralSuffixTest do
  use ExUnit.Case, async: true

  alias Idiom.Languages

  test "gets the current suffix for a supported locale" do
    locale = "en"
    count = 1
    expected = "other"

    assert Languages.get_plural_suffix(locale, count: count) == expected
  end
end
