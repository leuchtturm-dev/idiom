defmodule Idiom.Source.PhraseStrings do
  use GenServer
  require Logger
  alias Idiom.Cache
  alias Idiom.Source.PhraseStrings.Strings
  alias Idiom.Source.PhraseStrings.OTA

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    Process.send(self(), {:fetch_data, 5}, [])

    {:ok, []}
  end

  def handle_info({:fetch_data, _retries}, state) do
    Logger.info("Fetching data from Phrase Strings")

    languages =
      Strings.list_available_languages()
      |> Enum.map(&get_data_for_language/1)
      |> Enum.map(&Cache.map_to_cache_data/1)
      |> Enum.reduce(%{}, fn keys, acc -> Map.merge(keys, acc) end)
      |> Cache.insert_keys()

    schedule_fetch()

    {:noreply, state}
  end

  defp schedule_fetch() do
    Process.send_after(self(), {:fetch_data, 5}, 60000)
  end

  defp get_data_for_language(lang) do
    Logger.info("Fetching data for #{lang}")

    OTA.get_strings(lang)
    |> then(&Map.new([{lang, %{"translations" => &1}}]))
  end
end
