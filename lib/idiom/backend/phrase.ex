defmodule Idiom.Backend.Phrase do
  @moduledoc """
  Backend for [Phrase](https://phrase.com).

  **Not yet complete. Use at your own risk. Things might break at any time.**

  ## Usage

  In order to use the Phrase backend, set it in your Idiom configuration:

  ```elixir
  config :idiom,
    backend: Idiom.Backend.Phrase
  ```

  ## Configuration

  The Phrase backend currently supports the following configuration options:

  ```elixir
  config :idiom, Idiom.Backend.Phrase,
    distribution_id: "", # required
    distribution_secret: "", # required
    locales: ["de-DE", "en-US"], # required
    base_url: "https://ota.eu.phrase.com",
    fetch_interval: 600_000
  ```

  ### Creating a distribution

  In order to create a Phrase Strings OTA distribution, head to the "Over the air" page in your Phrase dashboard and create a distribution using the
  `i18next (React Native)` platform. This will give you a Distribution ID as well as a secret for both development and production environments.
  """

  use GenServer
  alias Idiom.Cache
  require Logger

  #foo

  @opts_schema [
    distribution_id: [
      type: :string,
      required: true
    ],
    distribution_secret: [
      type: :string,
      required: true
    ],
    locales: [
      type: {:list, :string},
      required: true
    ],
    base_url: [
      type: :string,
      default: "https://ota.eu.phrase.com"
    ],
    fetch_interval: [
      type: :non_neg_integer,
      default: 600_000
    ]
  ]

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    case NimbleOptions.validate(opts, @opts_schema) do
      {:ok, opts} ->
        Process.send(self(), :fetch_data, [])
        uuid = Uniq.UUID.uuid6()

        {:ok, %{uuid: uuid, last_update: nil, opts: opts}}

      {:error, %{message: message}} ->
        raise "Could not start `Idiom.Backend.Phrase` due to invalid configuration: #{message}"
    end
  end

  @impl GenServer
  def handle_info(:fetch_data, %{uuid: uuid, last_update: last_update, opts: opts} = state) do
    fetch_data(uuid, last_update, opts)
    |> Cache.insert_keys()

    interval = Keyword.get(opts, :fetch_interval)
    schedule_refresh(interval)

    last_update = DateTime.utc_now() |> DateTime.to_unix()
    {:noreply, %{state | last_update: last_update}}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :fetch_data, interval)
  end

  defp fetch_data(uuid, last_update, opts) do
    params = [client: "idiom", unique_identifier: uuid, last_update: last_update]

    %{locales: locales, base_url: base_url, distribution_id: distribution_id, distribution_secret: distribution_secret} = Map.new(opts)

    Enum.map(locales, &fetch_locale(base_url, distribution_id, distribution_secret, &1, params))
    |> Enum.reduce(%{}, fn locale, acc -> Map.merge(locale, acc) end)
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
