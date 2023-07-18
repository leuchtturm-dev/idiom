defmodule Idiom.Source.PhraseStrings do
  use GenServer
  alias Idiom.Source.PhraseStrings.HTTP

  def init(opts) do
    {:ok, []}
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_info(:fetch, state) do
    # NOTE: Fetch and write into cache
    HTTP.get_deployment("54070a20cb50153126e891eaee37121a", "K14wARUvEikIj_7-HlnuZc0uFLG1w_OgUviNi5mDpsQ", "en")
    |> IO.inspect()

    schedule_fetch()

    {:noreply, state}
  end

  defp schedule_fetch() do
    Process.send_after(self(), :fetch, 100000)
  end
end
