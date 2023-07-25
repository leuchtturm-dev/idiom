defmodule Idiom.Source.PhraseStrings.OTA do
  # TODO:
  @moduledoc """
  """

  use Tesla

  adapter Tesla.Adapter.Finch, name: IdiomFinch

  plug Tesla.Middleware.BaseUrl, "https://ota.eu.phrase.com/"
  plug Tesla.Middleware.FollowRedirects, max_redirects: 3
  plug Tesla.Middleware.JSON

  # TODO:
  @doc """
  """
  def get_strings(locale) do
    with distribution_id when is_binary(distribution_id) <- Application.get_env(:idiom, Idiom.Source.PhraseStrings)[:distribution_id],
         distribution_secret when is_binary(distribution_secret) <- Application.get_env(:idiom, Idiom.Source.PhraseStrings)[:distribution_secret],
         {:ok, %{status: 200, body: body}} <- get("/#{distribution_id}/#{distribution_secret}/#{locale}/i18next_4") do
      body
    end
  end
end
