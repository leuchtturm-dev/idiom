defmodule Idiom.Source.Local do
  alias Idiom.Cache

  def data(opts \\ []) do
    # TODO: find name for this opt and figure out opts in general
    # config :idiom, local_data_path: "foo"
    # or
    # config :idiom, Idiom.Source.Local, path: "foo"
    Keyword.get(opts, :local_data_path, "priv/idiom")
    |> Path.join("**/*.json")
    |> Path.wildcard()
    |> Enum.map(&parse_file/1)
    |> Enum.map(&Cache.map_to_cache_data/1)
    |> Enum.reduce(%{}, fn keys, acc -> Map.merge(keys, acc) end)
  end

  defp parse_file(path) do
    with {:ok, contents} <- File.read(path),
         {:ok, map} <- Jason.decode(contents),
         {lang, domain} <- extract_lang_and_domain(path) do
      [{lang, Map.new([{domain, map}])}]
      |> Map.new()
    end
  end

  defp extract_lang_and_domain(path) do
    path |> String.split("/") |> Enum.reverse() |> Enum.take(2) |> Enum.map(&Path.rootname/1) |> Enum.reverse() |> List.to_tuple()
  end
end
