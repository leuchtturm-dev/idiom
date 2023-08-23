defmodule Idiom.Backend.Phrase do
  # TODO: moduledoc
  @moduledoc ""

  # TODO:
  # The plan for this module is
  #   - to have locales configurable in application configuration, but also allow them to be fetched from Strings API (requires extra authentication)
  #   - default configuration should look something like
  #     config :idiom, Idiom.Backend.Phrase,
  #       locales: ["de-DE", "en-US"],
  #       fetch_locales_from_strings: false,
  #       fetch_interval: 120_000,
  #       ... credentials
  #   - ask Soenke for a way to get available locales without Strings API credentials?
  # Open questions:
  #   - How are namespaces assigned?
  #     For keys like `signup.foo`, have `signup` be the namespace? What about keys without a dot?

  use GenServer
  alias Idiom.Cache

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    Process.send(self(), :fetch_data, [])

    locales = Keyword.get(opts, :locales, [])

    {:ok, [locales: locales]}
  end

  def handle_info(:fetch_data, state) do
    ["de-DE"]
    |> Enum.map(&fetch_data/1)
    |> Enum.reduce(%{}, fn data, acc -> Map.merge(data, acc) end)
    |> Cache.insert_keys()

    schedule_refresh()

    {:noreply, state}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :fetch_data, 1_000)
  end

  defp fetch_data(locale) do
    with distribution_id when is_binary(distribution_id) <- "54070a20cb50153126e891eaee37121a",
         distribution_secret when is_binary(distribution_secret) <- "K14wARUvEikIj_7-HlnuZc0uFLG1w_OgUviNi5mDpsQ",
         {:ok, response} <- Req.get("https://ota.eu.phrase.com//#{distribution_id}/#{distribution_secret}/#{locale}/i18next_4") do
      Map.new([{locale, %{"default" => response.body}}])
    end
  end
end
