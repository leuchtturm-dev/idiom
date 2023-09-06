defmodule Idiom.Backend.Lokalise do
  @moduledoc """
  Backend for [Lokalise](https://lokalise.com).

  **Not yet complete. Use at your own risk. Things might break at any time.**

  ## Usage

  In order to use the Lokalise backend, set it in your Idiom configuration:

  ```elixir
  config :idiom,
    backend: Idiom.Backend.Lokalise
  ```

  ## Configuration

  The Lokalise backend currently supports the following configuration options:

  ```elixir
  config :idiom, Idiom.Backend.Lokalise,
    # TODO
  ```

  """

  use GenServer

  alias Idiom.Backend.Utilities
  alias Idiom.Cache

  require Logger

  @opts_schema [
    project_id: [type: :string, required: true],
    api_token: [type: :string, required: true],
    namespace: [
      type: :string,
      default: "default"
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
        opts = Utilities.maybe_add_app_version_to_opts(opts, opts[:otp_app])

        Process.send(self(), :fetch_data, [])

        {:ok, %{current_version: 0, opts: opts}}

      {:error, %{message: message}} ->
        raise "Could not start `Idiom.Backend.Lokalise` due to invalid configuration: #{message}"
    end
  end

  @impl GenServer
  def handle_info(:fetch_data, %{current_version: current_version, opts: opts} = state) do
    current_version = fetch_data(current_version, opts)

    opts
    |> Keyword.get(:fetch_interval)
    |> schedule_refresh()

    {:noreply, %{state | current_version: current_version}}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :fetch_data, interval)
  end

  defp fetch_data(current_version, opts) do
    namespace = Keyword.get(opts, :namespace)

    with {:ok, %{body: %{"data" => %{"url" => url, "version" => version}}}} <-
           fetch_current_bundle(current_version, opts),
         {:ok, %{body: body}} <- fetch_bundle(url) do
      body
      |> Idiom.Formats.Lokalise.transform(namespace)
      |> Cache.insert_keys()

      Logger.debug("Idiom.Backend.Lokalise: Updated cache with version #{version}")

      version
    else
      {:ok, %Req.Response{status: 204}} ->
        Logger.debug("Idiom.Backend.Lokalise: No new version - skipping cache update")

        current_version

      {:error, error} ->
        Logger.error(
          "Idiom.Backend.Lokalise: Failed fetching data from Lokalise - #{inspect(error)}"
        )
    end
  end

  defp fetch_current_bundle(current_version, opts) do
    %{project_id: project_id, api_token: api_token, app_version: app_version} =
      Map.new(opts)

    [
      base_url: "https://ota.lokalise.com",
      url: "/v3/lokalise/projects/#{project_id}/frameworks/android_sdk",
      params: [{"appVersion", app_version}, {"transVersion", current_version}],
      headers: [{"x-ota-api-token", api_token}]
    ]
    |> Req.new()
    |> Req.get()
  end

  defp fetch_bundle(url) do
    [url: url] |> Req.new() |> Req.get()
  end
end
