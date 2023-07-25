defmodule Idiom.Source.PhraseStrings.Strings do
  # TODO:
  @moduledoc """
  """
  use Tesla

  adapter Tesla.Adapter.Finch, name: IdiomFinch

  plug Tesla.Middleware.BaseUrl, "https://api.phrase.com/v2"
  plug Tesla.Middleware.FollowRedirects, max_redirects: 3
  plug Tesla.Middleware.JSON

  def client do
    api_token = Application.get_env(:idiom, Idiom.Source.PhraseStrings)[:api_token]

    Tesla.client([
      {Tesla.Middleware.Headers, [{"Authorization", "token #{api_token}"}]}
    ])
  end

  def list_available_languages() do
    with account_id when is_binary(account_id) <- Application.get_env(:idiom, Idiom.Source.PhraseStrings)[:account_id],
         distribution_id when is_binary(distribution_id) <- Application.get_env(:idiom, Idiom.Source.PhraseStrings)[:distribution_id],
         {:ok, %{body: body, status: 200}} <- get(client(), "/accounts/#{account_id}/distributions/#{distribution_id}/releases"),
         sorted_releases when is_list(sorted_releases) <- Enum.sort_by(body, &Map.get(&1, "created_at")),
         latest_release <- List.first(sorted_releases) do
      Map.get(latest_release, "locale_codes")
    end
  end
end
