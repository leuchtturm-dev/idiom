defmodule Idiom.Backend.Utilities do
  @moduledoc """
  Utilities for writing Idiom backends.
  """

  @doc """
  Adds an `app_version` field to the `GenServer` options if the `otp_app` configuration field was provided. 

  The application version is read from `mix.exs`.
  """
  def maybe_add_app_version_to_opts(opts, nil), do: opts

  def maybe_add_app_version_to_opts(opts, otp_app) do
    app_version = otp_app |> Application.spec(:vsn) |> to_string()

    Keyword.put(opts, :app_version, app_version)
  end
end
