defmodule Idiom.Idiom.PutLocaleTest do
  use ExUnit.Case, async: false

  setup_all do
    on_exit(fn -> Process.delete(:idiom_locale) end)
  end

  test "puts the value into the process dictionary - 1" do
    Idiom.put_locale("en-US")

    assert Process.get(:idiom_locale) == "en-US"
  end

  test "puts the value into the process dictionary - 2" do
    Idiom.put_locale("zh-Hant-HK")

    assert Process.get(:idiom_locale) == "zh-Hant-HK"
  end
end
