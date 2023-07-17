defmodule Idiom.Source.Local do
  require Logger

  alias Idiom.Cache

  def data(opts \\ []) do
    data_dir =
      Keyword.get(opts, :data_dir) ||
        Application.get_env(:idiom, __MODULE__)[:data_dir] ||
        "priv/idiom"

    Path.join(data_dir, "**/*.json")
    |> Path.wildcard()
    |> Enum.map(&parse_file/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&Cache.map_to_cache_data/1)
    |> Enum.reduce(%{}, fn keys, acc -> Map.merge(keys, acc) end)
  end

  defp parse_file(path) do
    with {:ok, contents} <- File.read(path),
         {:ok, map} <- Jason.decode(contents),
         {lang, domain} <- extract_lang_and_domain(path) do
      [{lang, Map.new([{domain, map}])}]
      |> Map.new()
    else
      {:error, _error} ->
        Logger.warning("Could not parse file #{path}")
        nil
    end
  end

  defp extract_lang_and_domain(path) do
    path |> String.split("/") |> Enum.reverse() |> Enum.take(2) |> Enum.map(&Path.rootname/1) |> Enum.reverse() |> List.to_tuple()
  end
end
