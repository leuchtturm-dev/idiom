defmodule Idiom.Idiom.PutNamespaceTest do
  use ExUnit.Case, async: false

  setup_all do
    on_exit(fn -> Process.delete(:idiom_namespace) end)
  end

  test "puts the value into the process dictionary - 1" do
    Idiom.put_namespace("translations")

    assert Process.get(:idiom_namespace) == "translations"
  end

  test "puts the value into the process dictionary - 2" do
    Idiom.put_namespace("signup")

    assert Process.get(:idiom_namespace) == "signup"
  end
end
