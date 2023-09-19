defmodule Idiom.Supervisor do
  @moduledoc false

  use Supervisor

  alias Idiom.Cache

  def start_link(options) when is_list(options) do
    options = Keyword.merge(default_options(), options)

    local_data = Idiom.Local.read()
    data = Keyword.get(options, :data, %{})

    local_data
    |> Map.merge(data)
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
      Enum.reject([{backend, backend_opts}], fn
        nil -> true
        {nil, _opts} -> true
        _ -> false
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
