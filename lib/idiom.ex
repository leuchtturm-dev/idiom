defmodule Idiom do
  alias Idiom.Translator

  defdelegate child_spec(options), to: Idiom.Supervisor

  def t(key, opts \\ []), do: translate(key, opts)

  def translate(key, opts \\ []) do
    Translator.translate(key, opts)
  end
end
