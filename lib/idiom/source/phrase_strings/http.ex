defmodule Idiom.Source.PhraseStrings.HTTP do
  use Tesla

  adapter Tesla.Adapter.Finch, name: IdiomFinch

  plug Tesla.Middleware.BaseUrl, "https://ota.phrase.com/"

  def get_deployment(distribution_id, secret, locale) do
    get("/#{distribution_id}/#{secret}/#{locale}/i18next_4")
  end
end
