defmodule Idiom.Backend.Utilities do
  @moduledoc false
  def maybe_add_app_version_to_opts(opts, nil), do: opts

  def maybe_add_app_version_to_opts(opts, otp_app) do
    app_version = otp_app |> Application.spec(:vsn) |> to_string()

    Keyword.put(opts, :app_version, app_version)
  end
end
