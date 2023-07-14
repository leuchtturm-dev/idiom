defmodule Idiom do
  alias Idiom.Translator

  defdelegate child_spec(options), to: Idiom.Supervisor

  def t(key, opts \\ []), do: translate(key, opts)

  def translate(key, opts \\ []) do
    opts
    |> backend()
    |> Translator.translate(key, opts)
  end

  defp backend(options) do
    options
    |> Keyword.get(:backend, __MODULE__)
    |> Idiom.Supervisor.backend_name()
  end
end
