defmodule Idiom.Idiom.GetLocaleTest do
  use ExUnit.Case, async: true

  describe "with value from process dictionary" do
    test "returns the value from the process dictionary" do
      Process.put(:idiom_locale, "zh-Hant-HK")

      assert Idiom.get_locale() == "zh-Hant-HK"
    end
  end

  describe "with default language" do
    test "returns the value from the application configuration" do
      Application.put_env(:idiom, :default_locale, "de-DE")

      assert Idiom.get_locale() == "de-DE"
    end
  end
end
