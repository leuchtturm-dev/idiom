defmodule Idiom.Translator do
  alias Idiom.Cache

  def translate(key, opts \\ [])
  def translate(nil, _opts), do: ""

  def translate(key, opts) do
    cache_table_name = Keyword.get(opts, :cache_table_name)

    lang = Keyword.get(opts, :to) || raise "No language provided"
    {namespace, key} = extract_namespace(key, opts)
    langs = to_resolve_hierarchy(lang, opts)

    Enum.find_value(langs, fn lang -> Cache.get_translation(lang, namespace, key, cache_table_name) end)
  end

  @doc false
  def to_resolve_hierarchy(code, opts \\ []) do
    fallback_lang = Keyword.get(opts, :fallback_lang)

    ([code, get_script_part_from_code(code), get_language_part_from_code(code)] ++ List.wrap(fallback_lang))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

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

  defp get_script_part_from_code(code) do
    if String.contains?(code, "-") do
      String.replace(code, "_", "-")
      |> String.split("-")
      |> case do
        nil -> nil
        parts when is_list(parts) and length(parts) == 2 -> nil
        # TODO: Format language code
        parts when is_list(parts) -> Enum.take(parts, 2) |> Enum.join("-")
      end
    else
      code
    end
  end

  defp get_language_part_from_code(code) do
    if String.contains?(code, "-") do
      String.replace(code, "_", "-") |> String.split("-") |> List.first()
    else
      code
    end
  end
end
