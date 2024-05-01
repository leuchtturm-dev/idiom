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
    datacenter: "eu", # or "us"
    distribution_id: "", # required
    distribution_secret: "", # required
    locales: ["de-DE", "en-US"], # required
    namespace: "default",
    fetch_interval: 600_000,
    otp_app: nil # optional, for Phrase's appVersion support
  ```

  ### Creating a distribution

  In order to create a Phrase Strings OTA distribution, head to the "Over the air" page in your Phrase dashboard and create a distribution using the
  `i18next (React Native)` platform. This will give you a Distribution ID as well as a secret for both development and production environments.
  """

  use GenServer

  alias Idiom.Backend.Utilities
  alias Idiom.Cache

  require Logger

  @opts_schema [
    datacenter: [
      type: :string,
      default: "eu"
    ],
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
        interval = Keyword.get(opts, :fetch_interval)
        {:ok, timer} = :timer.send_interval(interval, self(), :update_data)

        otp_app = Keyword.get(opts, :otp_app)

        initial_state =
          opts
          |> Utilities.maybe_add_app_version_to_opts(otp_app)
          |> Map.new()
          |> Map.put(:current_version, nil)
          |> Map.put(:last_update, nil)
          |> Map.put(:timer, timer)

        send(self(), :update_data)

        {:ok, initial_state}

      {:error, %{message: message}} ->
        {:error, message}
    end
  end

  @impl GenServer
  def handle_info(:update_data, state) do
    %{
      locales: locales,
      namespace: namespace
    } = state

    request_params =
      Map.take(state, [
        :datacenter,
        :distribution_id,
        :distribution_secret,
        :app_version,
        :current_version,
        :last_update
      ])

    new_version = update_data(locales, namespace, request_params)

    {:noreply, %{state | current_version: new_version, last_update: last_update_now()}}
  end

  defp update_data(locales, namespace, request_params) do
    locales
    |> Enum.map(&fetch_locale(&1, namespace, request_params))
    # When the Phrase OTA API returns multiple different versions, store the lowest
    # one so that at the next refresh all locales are requested again to update to the
    # newest version.
    |> Enum.min()
  end

  defp fetch_locale(locale, namespace, request_params) do
    %{
      datacenter: datacenter,
      distribution_id: distribution_id,
      distribution_secret: distribution_secret,
      current_version: current_version,
      last_update: last_update
    } = request_params

    params = [
      client: "idiom",
      app_version: Map.get(request_params, :app_version),
      current_version: current_version,
      last_update: last_update
    ]

    case [
           url: "#{distribution_id}/#{distribution_secret}/#{locale}/i18next_4",
           base_url: base_url(datacenter),
           params: params
         ]
         |> Req.new()
         |> Req.Request.append_response_steps(add_version_to_response: &add_version_to_response/1)
         |> Req.get() do
      {:ok, %Req.Response{status: 304}} ->
        Logger.debug("Idiom.Backend.Phrase: No new version for #{locale} - skipping cache update")

        current_version

      {:ok, %Req.Response{body: body} = response} ->
        version = Req.Response.get_private(response, :version)

        [{locale, %{namespace => body}}]
        |> Map.new()
        |> Cache.insert_keys()

        Logger.debug("Idiom.Backend.Phrase: Updated cache for #{locale} with version #{version}")

        version

      error ->
        Logger.error("Idiom.Backend.Phrase: Failed fetching data from Phrase - #{inspect(error)}")

        current_version
    end
  end

  defp add_version_to_response({%{url: %{query: query}} = request, response}) do
    version =
      query
      |> URI.decode_query()
      |> Map.get("version")
      |> case do
        nil -> nil
        version when is_integer(version) -> version
        version when is_binary(version) -> String.to_integer(version)
      end

    {request, Req.Response.put_private(response, :version, version)}
  end

  defp last_update_now, do: DateTime.to_unix(DateTime.utc_now())

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
