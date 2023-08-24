defmodule Idiom.Backend.Phrase do
  @moduledoc """
  Backend for [Phrase](https://phrase.com).

  **Not yet complete. Use at your own risk. The API might change without notice.**
  """

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

  use GenServer
  alias Idiom.Cache

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    Process.send(self(), :fetch_data, [])

    uuid = Uniq.UUID.uuid6()
    {:ok, %{uuid: uuid, last_update: nil, opts: opts}}
  end

  def handle_info(:fetch_data, %{uuid: uuid, last_update: last_update, opts: opts} = state) do
    fetch_data(uuid, last_update, opts)
    |> Cache.insert_keys()

    interval = Keyword.get(opts, :fetch_interval, 600_000)
    schedule_refresh(interval)

    last_update = DateTime.utc_now() |> DateTime.to_unix()
    {:noreply, %{state | last_update: last_update}}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :fetch_data, interval)
  end

  defp fetch_data(uuid, last_update, opts) do
    params = [client: "idiom", unique_identifier: uuid, last_update: last_update]

    with base_url when is_binary(base_url) <- Keyword.get(opts, :base_url, "https://ota.eu.phrase.com"),
         distribution_id when is_binary(distribution_id) <- Keyword.get(opts, :distribution_id),
         distribution_secret when is_binary(distribution_secret) <- Keyword.get(opts, :distribution_secret) do
      Keyword.get(opts, :locales, [])
      |> Enum.map(&fetch_locale(base_url, distribution_id, distribution_secret, &1, params))
      |> Enum.reduce(%{}, fn locale, acc -> Map.merge(locale, acc) end)
    end
  end

  defp fetch_locale(base_url, distribution_id, distribution_secret, locale, params) do
    case Req.get("#{distribution_id}/#{distribution_secret}/#{locale}/i18next_4", base_url: base_url, params: params) do
      {:ok, response} ->
        Map.new([{locale, %{"default" => response.body}}])

      _ ->
        %{}
    end
  end
end
