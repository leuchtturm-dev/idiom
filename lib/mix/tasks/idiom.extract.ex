defmodule Mix.Tasks.Idiom.Extract do
  @moduledoc false
  use Mix.Task

  alias Idiom.Extract

  # TODO: impl merge
  @switches [data_dir: :string, default_namespace: :string, files: :string, merge: :boolean]

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, switches: @switches)

    Extract.create_table()
    Application.put_env(:idiom, :extracting?, true)

    Mix.Task.clear()
    Mix.Task.run("compile", ["--force"])

    base_dir =
      Keyword.get(opts, :data_dir) ||
        Application.get_env(:idiom, :data_dir) ||
        "priv/idiom"

    template_dir = Path.join(base_dir, "template")
    File.mkdir_p!(template_dir)

    default_namespace = Keyword.get(opts, :default_namespace) || Idiom.get_namespace()

    included_file_list =
      opts
      |> Keyword.get(:files, "lib/**")
      |> Path.wildcard()
      |> Enum.map(&Path.expand/1)

    :extracted_keys
    |> :ets.tab2list()
    |> Enum.filter(fn {%{file: file}} -> file in included_file_list end)
    |> Enum.map(fn
      {%{has_count?: true, plural: plural} = data} ->
        generate_suffix_keys(data, plural)

      {data} ->
        data
    end)
    |> List.flatten()
    |> Enum.group_by(fn
      %{namespace: nil} -> default_namespace
      %{namespace: namespace} -> namespace
    end)
    |> Enum.map(fn {namespace, data} ->
      data =
        Enum.reduce(data, %{}, fn %{key: key}, acc -> Map.put(acc, key, key) end)

      template_dir
      |> Path.join([namespace, ".json"])
      |> File.write!(Jason.encode!(data, pretty: true))
    end)
  end

  defp generate_suffix_keys(data, plural) do
    "en"
    |> Idiom.Plural.get_suffixes(plural)
    |> Enum.map(fn suffix ->
      Map.update!(data, :key, &(&1 <> "_" <> suffix))
    end)
  end
end
