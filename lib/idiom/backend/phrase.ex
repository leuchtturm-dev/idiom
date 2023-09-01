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

        {:ok, %{uuid: uuid, per_locale_state: %{}, opts: opts}}

      {:error, %{message: message}} ->
        raise "Could not start `Idiom.Backend.Phrase` due to invalid configuration: #{message}"
    end
  end

  @impl GenServer
  def handle_info(:fetch_data, %{uuid: uuid, per_locale_state: per_locale_state, opts: opts} = state) do
    per_locale_state = fetch_data(uuid, per_locale_state, opts)

    interval = Keyword.get(opts, :fetch_interval)
    schedule_refresh(interval)

    {:noreply, %{state | per_locale_state: per_locale_state}}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :fetch_data, interval)
  end

  defp fetch_data(uuid, per_locale_state, opts) do
    %{locales: locales, base_url: base_url, distribution_id: distribution_id, distribution_secret: distribution_secret} = Map.new(opts)

    Enum.map(locales, &fetch_locale(uuid, base_url, distribution_id, distribution_secret, &1, per_locale_state))
    |> Enum.reduce(per_locale_state, fn locale_state, acc -> Map.merge(acc, locale_state) end)
  end

  defp fetch_locale(uuid, base_url, distribution_id, distribution_secret, locale, per_locale_state) do
    locale_state =
      Map.get(per_locale_state, locale, %{current_version: nil, last_update: nil})

    params = [client: "idiom", unique_identifier: uuid, current_version: locale_state.current_version, last_update: locale_state.last_update]

    case Req.new(url: "#{distribution_id}/#{distribution_secret}/#{locale}/i18next_4", base_url: base_url, params: params)
         |> Req.Request.append_response_steps(add_version_to_response: &add_version_to_response/1)
         |> Req.get() do
      {:ok, %Req.Response{body: body} = response} ->
        Map.new([{locale, %{"default" => body}}])
        |> Cache.insert_keys()

        [{locale, %{current_version: Req.Response.get_private(response, :version), last_update: last_update()}}]
        |> Map.new()

      {:ok, %Req.Response{status: 304}} ->
        Map.new([{locale, locale_state}])

      _error ->
        Map.new([{locale, locale_state}])
    end
  end

  defp add_version_to_response({%{url: %{query: query}} = request, response}) do
    version =
      query
      |> URI.decode_query()
      |> Map.get("version", 1)

    {request, Req.Response.put_private(response, :version, version)}
  end

  defp last_update(), do: DateTime.utc_now() |> DateTime.to_unix()
end
