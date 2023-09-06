defmodule Idiom.Extract do
  @moduledoc false

  def create_table do
    :ets.new(:extracted_keys, [:public, :named_table])
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
