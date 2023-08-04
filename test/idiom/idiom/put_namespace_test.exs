defmodule Idiom.Idiom.PutNamespaceTest do
  use ExUnit.Case, async: true

  test "puts the value into the process dictionary - 1" do
    Idiom.put_namespace("en-US")

    assert Process.get(:idiom_namespace) == "en-US"
  end

  test "puts the value into the process dictionary - 2" do
    Idiom.put_namespace("zh-Hant-HK")

    assert Process.get(:idiom_namespace) == "zh-Hant-HK"
  end
end
