defmodule Idiom.Interpolation do
  @moduledoc """
  Functionality for interpolating variables into a message.
  """

  @doc """
  Interpolates a message with a map of bindings.

  The message can include variables wrapped in `{{}}`. For example, in the string `Hello, {{name}}!`, `{{name}}` is a variable. If a variable exists in the 
  message , but not in the bindings, it is converted to a string in-place.

  The binding can be any value that implements the `String.Chars` protocol.

  ## Examples

  ```elixir
  iex> Idiom.Interpolation.interpolate("Hello, {{name}}!", %{name: "John"})
  "Hello, John!"

  iex> Idiom.Interpolation.interpolate("Hello, {{name}}! It is {{day_of_week}}.", %{name: "John", day_of_week: "Monday"})
  "Hello, John! It is Monday."

  iex> Idiom.Interpolation.interpolate("Hello, {{name}}! It is {{day_of_week}}.", %{name: "John"})
  "Hello, John! It is day_of_week."
  ```
  """
  @spec interpolate(String.t(), map()) :: String.t()
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
    parts
    |> Enum.reverse()
    |> Enum.join("")
  end

  defp parse(message) when is_binary(message) do
    message
    |> parse([])
    |> Enum.reject(fn part -> is_binary(part) and String.equivalent?(part, "") end)
    |> Enum.reverse()
  end

  defp parse(message, acc) do
    # Using Erlang's `:binary.split/2` with `global` disabled instead of `String.split/3` to only split at the first occurence.
    case :binary.split(message, :binary.compile_pattern("{{")) do
      [part] ->
        [part | acc]

      [previous_part, possible_binding_and_rest] ->
        case :binary.split(possible_binding_and_rest, :binary.compile_pattern("}}")) do
          [_rest] ->
            [message | acc]

          [binding, rest] ->
            parse(rest, [String.to_atom(binding) | [previous_part | acc]])
        end
    end
  end
end
