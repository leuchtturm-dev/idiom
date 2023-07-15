defmodule Idiom.Translator do
  alias Idiom.Cache
  alias Idiom.Languages

  def translate(key, opts \\ [])
  def translate(nil, _opts), do: ""

  def translate(key, opts) do
    cache_table_name = Keyword.get(opts, :cache_table_name)

    lang = Keyword.get(opts, :to) || raise "No language provided"
    {namespace, key} = extract_namespace(key, opts)
    langs = Languages.to_resolve_hierarchy(lang, opts)

    Enum.find_value(langs, fn lang -> Cache.get_translation(lang, namespace, key, cache_table_name) end)
  end

  @doc false
  defp extract_namespace(key, opts) do
    default_namespace = Keyword.get(opts, :default_namespace, "translation")
    namespace_separator = Keyword.get(opts, :namespace_separator, ":")
    key_separator = Keyword.get(opts, :key_separator, ".")

    if String.contains?(key, namespace_separator) do
      [namespace | key_parts] = String.split(key, namespace_separator)
      {namespace, Enum.join(key_parts, key_separator)}
    else
      {default_namespace, key}
    end
  end
end
