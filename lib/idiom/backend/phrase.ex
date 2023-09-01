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
    datacenter: "eu",
    fetch_interval: 600_000,
    otp_app: :foo # optional, for Phrase's appVersion support
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
    datacenter: [
      type: :string,
      default: "eu"
    ],
    fetch_interval: [
      type: :non_neg_integer,
      default: 600_000
    ],
    otp_app: [
      type: :atom
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
        opts = maybe_add_app_version_to_opts(opts, opts[:otp_app])

        {:ok, %{uuid: uuid, current_version: nil, last_update: nil, opts: opts}}

      {:error, %{message: message}} ->
        raise "Could not start `Idiom.Backend.Phrase` due to invalid configuration: #{message}"
    end
  end

  @impl GenServer
  def handle_info(:fetch_data, %{uuid: uuid, current_version: current_version, last_update: last_update, opts: opts} = state) do
    current_version =
      fetch_data(uuid, current_version, last_update, opts)
      |> Enum.map(& &1.current_version)
      |> Enum.min()

    interval = Keyword.get(opts, :fetch_interval)
    schedule_refresh(interval)

    {:noreply, %{state | current_version: current_version, last_update: last_update_now()}}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :fetch_data, interval)
  end

  defp fetch_data(uuid, current_version, last_update, opts) do
    locales = Keyword.get(opts, :locales)

    Enum.map(locales, &fetch_locale(uuid, &1, current_version, last_update, opts))
  end

  defp fetch_locale(uuid, locale, current_version, last_update, opts) do
    %{datacenter: datacenter, distribution_id: distribution_id, distribution_secret: distribution_secret, app_version: app_version} = Map.new(opts)

    params = [
      client: "idiom",
      unique_identifier: uuid,
      app_version: app_version,
      current_version: current_version,
      last_update: last_update
    ]

    case Req.new(url: "#{distribution_id}/#{distribution_secret}/#{locale}/i18next_4", base_url: base_url(datacenter), params: params)
         |> Req.Request.append_response_steps(add_version_to_response: &add_version_to_response/1)
         |> Req.get() do
      {:ok, %Req.Response{status: 304}} ->
        %{current_version: current_version}

      {:ok, %Req.Response{body: body} = response} ->
        Map.new([{locale, %{"default" => body}}])
        |> Cache.insert_keys()

        %{current_version: Req.Response.get_private(response, :version)}

      _error ->
        %{current_version: current_version}
    end
  end

  defp maybe_add_app_version_to_opts(opts, nil), do: opts

  defp maybe_add_app_version_to_opts(opts, otp_app) do
    app_version = Application.spec(otp_app, :vsn) |> to_string()

    Keyword.put(opts, :app_version, app_version)
  end

  defp add_version_to_response({%{url: %{query: query}} = request, response}) do
    version =
      query
      |> URI.decode_query()
      |> Map.get("version", "0")
      |> String.to_integer()

    {request, Req.Response.put_private(response, :version, version)}
  end

  defp last_update_now(), do: DateTime.utc_now() |> DateTime.to_unix()

  defp base_url(datacenter) do
    case datacenter do
      "us" ->
        "https://ota.us.phrase.com"

      "eu" ->
        "https://ota.eu.phrase.com"

      _ ->
        Logger.error("#{datacenter} is not a valid Phrase datacenter. Falling back to `eu`.")

        "https://ota.eu.phrase.com"
    end
  end
end
