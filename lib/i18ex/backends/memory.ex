defmodule I18ex.Backends.Memory do
  use GenServer

  def start_link(options) do
    with {name, options} <- Keyword.pop!(options, :name) do
      GenServer.start_link(__MODULE__, Map.new(options), name: name)
    end
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:get_resource, language, namespace, key}, _from, state) do
    result = do_get_resource(language, namespace, key, state)
    {:reply, result, state}
  end

  defp do_get_resource(language, namespace, key, state) do
    "test_en"
    # {:error, :not_found}
  end
end
