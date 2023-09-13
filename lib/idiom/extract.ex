defmodule Idiom.Extract do
  @moduledoc false

  use Agent

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def keys do
    Agent.get(__MODULE__, & &1)
  end

  def add_key(key) do
    Agent.update(__MODULE__, &Enum.uniq([key | &1]))
  end

  def expand_to_binary(term, env) do
    case Macro.expand(term, env) do
      term when is_binary(term) ->
        term

      {:<<>>, _, pieces} ->
        if Enum.all?(pieces, &is_binary/1), do: Enum.join(pieces), else: nil

      _other ->
        nil
    end
  end
end
