defmodule Idiom.Supervisor do
  @moduledoc false

  use Supervisor

  alias Idiom.Cache

  def start_link(options) when is_list(options) do
    options =
      default_options()
      |> Keyword.merge(options)

    local_data = Idiom.Local.data()
    data = Keyword.get(options, :data, %{})

    Map.merge(local_data, data)
    |> Cache.init()

    name = Keyword.fetch!(options, :name)
    Supervisor.start_link(__MODULE__, options, name: name)
  end

  defp default_options do
    [name: Idiom]
  end

  @impl Supervisor
  def init(_opts) do
    backend = Application.get_env(:idiom, :backend, nil)
    backend_opts = Application.get_env(:idiom, backend, [])

    children =
      [
        {Finch, name: IdiomFinch},
        {backend, backend_opts}
      ]
      |> Enum.reject(fn
        nil -> true
        {nil, _opts} -> true
        _ -> false
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
