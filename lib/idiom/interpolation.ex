defmodule Idiom.Interpolation do
  @moduledoc """
  Functionality for interpolating variables into a message string.
  """

  @doc """
  Interpolates a message string with a map of bindings.

  The message string can include variables wrapped in `{{}}`. For example, in the string "Hello, {{name}}!", "{{name}}" is a variable.
  If a variable exists in the message string, but not in the bindings, it is converted to a string in-place.

  ## Examples

    iex> Idiom.Interpolation.interpolate("Hello, {{name}}!", %{name: "John"})
    "Hello, John!"

    iex> Idiom.Interpolation.interpolate("Hello, {{name}}! It is {{day_of_week}}.", %{name: "John", day_of_week: "Monday"})
    "Hello, John! It is Monday."

    iex> Idiom.Interpolation.interpolate("Hello, {{name}}! It is {{day_of_week}}.", %{name: "John"})
    "Hello, John! It is day_of_week."

  """
  def interpolate(message, bindings) do
    message
    |> parse()
    |> interpolate([], bindings)
  end

  defp interpolate([part | rest], parts, bindings) when is_binary(part) do
    interpolate(rest, [part | parts], bindings)
  end

  defp interpolate([part | rest], parts, bindings) when is_atom(part) do
    case bindings do
      %{^part => binding} -> interpolate(rest, [to_string(binding) | parts], bindings)
      %{} -> interpolate(rest, [to_string(part) | parts], bindings)
    end
  end

  defp interpolate([], parts, _bindings) do
    Enum.reverse(parts)
    |> IO.iodata_to_binary()
  end

  def parse(message) when is_binary(message) do
    parse(message, "", [])
    |> Enum.reject(fn part -> is_binary(part) and String.equivalent?(part, "") end)
    |> Enum.reverse()
  end

  defp parse(message, current, acc) do
    case :binary.split(message, :binary.compile_pattern("{{")) do
      [part] ->
        [part | acc]

      [previous_part, possible_binding_and_rest] ->
        case :binary.split(possible_binding_and_rest, :binary.compile_pattern("}}")) do
          [_rest] ->
            [current <> message | acc]

          [binding, rest] ->
            parse(rest, "", [String.to_atom(binding) | [previous_part | acc]])
        end
    end
  end
end
