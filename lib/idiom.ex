defmodule Idiom do
  alias Idiom.Translator

  defdelegate child_spec(options), to: Idiom.Supervisor

  def t(key, opts \\ []), do: translate(key, opts)

  def translate(key, opts \\ []) do
    lang = Keyword.get(opts, :to) || Application.get_env(:idiom, :default_lang)

    Translator.translate(lang, key, opts)
  end
end
