defmodule I18ex.Translator do
  def translate(key, opts \\ [])
  def translate(nil, _opts), do: ""

  def translate(backend, key, opts) do
    language =
      Keyword.get(opts, :language) || Keyword.get(opts, :default_language) || "en"

    {namespace, key} = extract_namespace(key, opts)

    GenServer.call(backend, {:get_resource, language, namespace, key})
  end

  def exists(backend, key, opts \\ []) do
    case GenServer.call(backend, {:get_resource, "en", "default", key}) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def extract_namespace(key, opts \\ []) do
    default_namespace = Keyword.get(opts, :default_namespace, "default")
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
