defmodule Idiom.Idiom.GetNamespaceTest do
  use ExUnit.Case, async: true

  describe "with value from process dictionary" do
    test "returns the value from the process dictionary" do
      Process.put(:idiom_namespace, "zh-Hant-HK")

      assert Idiom.get_namespace() == "zh-Hant-HK"
    end
  end

  describe "with default language" do
    test "returns the value from the application configuration" do
      Application.put_env(:idiom, :default_namespace, "de-DE")

      assert Idiom.get_namespace() == "de-DE"
    end
  end
end
