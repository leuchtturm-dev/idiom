defmodule Idiom.Translator do
  alias Idiom.LanguageUtils
  alias Idiom.Cache

  def translate(key, opts \\ [])
  def translate(nil, _opts), do: ""

  def translate(key, opts) do
    cache_table_name = Keyword.get(opts, :cache_table_name)

    language =
      Keyword.get(opts, :language) || Keyword.get(opts, :default_language) || "en"

    {namespace, key} = extract_namespace(key, opts)

    codes = to_resolve_hierarchy(language)

    Cache.get_translation(language, namespace, key, cache_table_name)
  end

  def exists(backend, key, opts \\ []) do
    case GenServer.call(backend, {:get_resource, "en", "default", key}) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def extract_namespace(key, opts \\ []) do
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

  def to_resolve_hierarchy(code, fallback_code \\ %{}) do
    ([code] ++ [get_script_part_from_code(code)] ++ [get_language_part_from_code(code)])
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  def get_script_part_from_code(code) do
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

  def get_language_part_from_code(code) do
    if String.contains?(code, "-") do
      String.replace(code, "_", "-") |> String.split("-") |> List.first()
    else
      code
    end
  end
end
