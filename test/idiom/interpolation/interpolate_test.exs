defmodule Idiom.Interpolation.InterpolateTest do
  use ExUnit.Case, async: true

  alias Idiom.Interpolation

  describe "when all bindings exist" do
    tests = [
      %{
        message: "{{count}} carrots",
        bindings: Macro.escape(%{count: 5}),
        expected: "5 carrots"
      },
      %{
        message: "It is {{month}} {{day}}, {{year}}",
        bindings: Macro.escape(%{month: "February", day: 3, year: 2023}),
        expected: "It is February 3, 2023"
      }
    ]

    for %{message: message, bindings: bindings, expected: expected} <- tests do
      test "correctly interpolates `#{message}` with bindings `#{inspect(bindings)}`" do
        assert Interpolation.interpolate(unquote(message), unquote(bindings)) ==
                 unquote(expected)
      end
    end
  end

  describe "when a binding is missing" do
    test "interpolates all bindings that exist" do
      assert Interpolation.interpolate("It is {{month}} {{day}}, {{year}}", %{
               month: "February",
               day: 3
             }) =~ "It is February 3"
    end

    test "inserts the binding as string" do
      assert Interpolation.interpolate("It is {{month}} {{day}}, {{year}}", %{
               month: "February",
               day: 3
             }) == "It is February 3, year"
    end
  end

  describe "when a binding is started but not ended" do
    test "leaves the rest of the message as a string" do
      assert Interpolation.interpolate("It is {{temperature degrees outside", %{
               temperature: 25
             }) == "It is {{temperature degrees outside"
    end
  end

  describe "when a binding is empty" do
    test "returns the interpolated message while removing the empty binding" do
      assert Interpolation.interpolate("It is {{}}{{month}} {{day}}", %{
               month: "February",
               day: 3
             }) == "It is February 3"
    end
  end
end
