defmodule Idiom.Backend.Lokalise do
  @moduledoc """
  Backend for [Lokalise](https://lokalise.com).
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
    project_id: "", # required
    api_token: "", # required
    namespace: "default",
    fetch_interval: 600_000,
    otp_app: nil # optional, for Lokalise's bundle freeze support
  ```
  ## Creating a bundle
  Lokalise does not officially support any third-party SDKs or web application
  libraries. The Idiom backend works by fetching a bundle in the format of Lokalise's
  official Android SDK and then transforming the data. This means that when you create
  a localisation bundle in the "Download" tab of your Lokalise dashboard, you need to
  select "Android SDK" under the "File format" setting.  
  The `project_id` and `api_token` values can be found under the "More -> Settings" 
  page where you can find your Project ID and can generate a "Lokalise OTA Token". 
  fixed
  """

  use GenServer

  alias Idiom.Backend.Utilities
  alias Idiom.Cache

  require Logger

  @opts_schema [
    project_id: [
      type: :string,
      required: true
    ],
    api_token: [
      type: :string,
      required: true
    ],
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
        initial_state =
          opts
          |> Utilities.maybe_add_app_version_to_opts(opts[:otp_app])
          |> Map.new()
          |> Map.put(:current_version, 0)

        Process.send(self(), :fetch_data, [])

        {:ok, initial_state}

      {:error, %{message: message}} ->
        {:error, message}
    end
  end

  @impl GenServer
  def handle_info(:fetch_data, state) do
    %{
      namespace: namespace,
      fetch_interval: fetch_interval
    } = state

    request_params =
      Map.take(state, [:project_id, :api_token, :app_version, :current_version, :namespace])

    new_version = fetch_data(namespace, request_params)

    schedule_refresh(fetch_interval)

    {:noreply, %{state | current_version: new_version}}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :fetch_data, interval)
  end

  defp fetch_data(namespace, request_params) do
    %{
      project_id: project_id,
      api_token: api_token,
      app_version: app_version,
      current_version: current_version
    } = request_params

    with {:ok, %{body: %{"data" => %{"url" => url, "version" => version}}}} <-
           fetch_bundle_info(project_id, api_token, app_version, current_version),
         {:ok, %{body: body}} <- fetch_bundle(url) do
      body
      |> transform_data(namespace)
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

        current_version
    end
  end

  defp fetch_bundle_info(project_id, api_token, app_version, current_version) do
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

  defp transform_data(data, namespace) do
    data
    |> Enum.map(fn %{"iso" => locale, "items" => items} ->
      Map.new([{locale, %{namespace => transform_items(items)}}])
    end)
    |> Enum.reduce(%{}, fn locale, acc -> Map.merge(acc, locale) end)
  end

  defp transform_items(items) do
    items
    |> Enum.map(&transform_item(&1))
    |> List.flatten()
    |> Map.new()
  end

  defp transform_item(%{"key" => key, "value" => value}) do
    # Key can either be a string or a stringified JSON object
    case Jason.decode(value) do
      {:ok, decoded_value} -> transform_item(key, decoded_value)
      {:error, _error} -> transform_item(key, value)
    end
  end

  defp transform_item(key, value) when is_binary(value), do: {key, value}

  defp transform_item(key, value) when is_map(value) do
    Enum.map(value, fn {suffix, value} -> {"#{key}_#{suffix}", value} end)
  end
end
