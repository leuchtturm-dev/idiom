defmodule Idiom.Supervisor do
  alias Idiom.Cache
  alias Idiom.Backends.Memory
  use Supervisor

  def start_link(options) when is_list(options) do
    options =
      default_options()
      |> Keyword.merge(options)

    name = Keyword.fetch!(options, :name)
    Supervisor.start_link(__MODULE__, options, name: name)
  end

  defp default_options do
    [name: Idiom]
  end

  @impl Supervisor
  def init(options) do
    local_data = Keyword.get(options, :local_data, %{})
    Cache.init(local_data)

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
