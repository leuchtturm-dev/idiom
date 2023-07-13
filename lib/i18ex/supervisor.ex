defmodule I18ex.Supervisor do
  alias I18ex.Backends.Memory
  use Supervisor

  def start_link(options) when is_list(options) do
    options =
      default_options()
      |> Keyword.merge(options)

    name = Keyword.fetch!(options, :name)
    Supervisor.start_link(__MODULE__, options, name: name)
  end

  defp default_options do
    [name: I18ex]
  end

  @impl Supervisor
  def init(options) do
    backend_options = Keyword.update!(options, :name, &backend_name/1)

    children =
      [
        {Memory, backend_options}
      ]
      |> Enum.reject(&is_nil/1)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def backend_name(name), do: :"#{name}.Backend"
end
