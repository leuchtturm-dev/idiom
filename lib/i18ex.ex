defmodule I18ex do
  alias I18ex.Translator

  defdelegate child_spec(options), to: I18ex.Supervisor

  def t(key, opts \\ []), do: translate(key, opts)

  def translate(key, opts \\ []) do
    opts
    |> backend()
    |> Translator.translate(key, opts)
  end

  defp backend(options) do
    options
    |> Keyword.get(:backend, __MODULE__)
    |> I18ex.Supervisor.backend_name()
  end
end
