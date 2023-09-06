defmodule Idiom.Local do
  @moduledoc """
  Local source for Idiom.

  Idiom is backend-agnostic and can be used with many different sources. By default, it also loads resources from the local filesystem at boot time. This can
  be turned off in configuration, but it is highly recommended to have it as a fallback in case your chosen backend is unavailable.

  ## Directory structure

  You can set the data directory changing the `:data_dir` setting `Idiom.Local` will use as such:

  ```elixir
  config :idiom, data_dir: "priv/idiom"
  ```

  Inside that directory, the structure should be as follows:

  ```
  priv/idiom
  └── en
    ├── default.json
    └── login.json
  ```

  Where `en` is the target locale and `default` and `login` are namespaces.

  ## File format

  The `json` files expected by `Idiom.Local` are a subset of the [i18next format](https://www.i18next.com/misc/json-format). The following example shows all of
  its features that Idiom currently supports.

  ```json
  {
    "key": "value",
    "keyDeep": {
      "inner": "value"
    },
    "keyInterpolate": "replace this {{value}}",
    "keyPluralSimple_one": "the singular",
    "keyPluralSimple_other": "the plural",
    "keyPluralMultipleEgArabic_zero": "the plural form 0",
    "keyPluralMultipleEgArabic_one": "the plural form 1",
    "keyPluralMultipleEgArabic_two": "the plural form 2",
    "keyPluralMultipleEgArabic_few": "the plural form 3",
    "keyPluralMultipleEgArabic_many": "the plural form 4",
    "keyPluralMultipleEgArabic_other": "the plural form 5",
  }
  ```
  """
  require Logger

  @doc """
  Parses all local data.
  """
  @spec data(keyword()) :: map()
  def data(opts \\ []) do
    data_dir =
      Keyword.get(opts, :data_dir) ||
        Application.get_env(:idiom, :data_dir) ||
        "priv/idiom"

    data_dir
    |> Path.join("*/*.json")
    |> Path.wildcard()
    |> Enum.map(&parse_file/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(%{}, fn keys, acc ->
      Map.merge(acc, keys, fn _k, v1, v2 -> Map.merge(v1, v2) end)
    end)
  end

  defp parse_file(path) do
    with {:ok, contents} <- File.read(path),
         {:ok, data} <- Jason.decode(contents),
         [locale, domain] <- extract_locale_and_domain(path) do
      Map.new([{locale, Map.new([{domain, data}])}])
    else
      {:error, _error} ->
        Logger.error("Idiom: Could not parse file #{path}")

        nil
    end
  end

  defp extract_locale_and_domain(path) do
    path
    |> String.split("/")
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.map(&Path.rootname/1)
    |> Enum.reverse()
  end
end
