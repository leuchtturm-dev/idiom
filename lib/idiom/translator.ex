defmodule Idiom.Translator do
  alias Idiom.Pluralizer
  alias Idiom.Cache
  alias Idiom.Languages

  def translate(lang, key, opts \\ [])
  def translate(_lang, nil, _opts), do: ""

  def translate(lang, key, opts) do
    cache_table_name = Keyword.get(opts, :cache_table_name, Cache.cache_table_name())

    count = Keyword.get(opts, :count)
    {namespace, key} = extract_namespace(key, opts)
    langs = Languages.to_resolve_hierarchy(lang, opts)

    keys =
      Enum.reduce(langs, [], fn lang, acc ->
        acc ++ [Cache.to_cache_key(lang, namespace, key), Cache.to_cache_key(lang, namespace, "#{key}_#{Pluralizer.get_suffix(lang, count)}")]
      end)

    Enum.find_value(keys, fn key -> Cache.get_key(key, cache_table_name) end)
  end

  @doc false
  defp extract_namespace(key, opts) do
    default_namespace = Keyword.get(opts, :default_namespace, "translations")
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
