defmodule Idiom.Idiom.GetNamespaceTest do
  use ExUnit.Case, async: false

  setup_all do
    on_exit(fn -> Process.delete(:idiom_namespace) end)
  end

  describe "with value from process dictionary" do
    test "returns the value from the process dictionary" do
      Process.put(:idiom_namespace, "signup")

      assert Idiom.get_namespace() == "signup"
    end
  end

  describe "with default language" do
    test "returns the value from the application configuration" do
      Application.put_env(:idiom, :default_namespace, "translations")

      assert Idiom.get_namespace() == "translations"
    end
  end
end
