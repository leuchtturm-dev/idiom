defmodule Mix.Tasks.Idiom.Extract do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Application.put_env(:idiom, :extracting?, true)
    :ets.new(:extracted_keys, [:public, :named_table])

    Mix.Task.clear()
    Mix.Task.run("compile", ["--force"])

    base_dir =
      Application.get_env(:idiom, :data_dir) ||
        "priv/idiom"

    template_dir =   Path.join(base_dir, "template")
    File.mkdir_p!(template_dir)

    :ets.tab2list(:extracted_keys)
    |> Enum.map(fn
      {%{has_count?: true} = data} ->
        generate_suffix_keys(data)

      {data} ->
        data
    end)
    |> List.flatten()
    |> Enum.group_by(fn
      %{namespace: nil} -> "default"
      %{namespace: namespace} -> namespace
    end)
    |> Enum.map(fn {namespace, data} ->
      data =
        Enum.reduce(data, %{}, fn %{key: key}, acc -> Map.put(acc, key, key) end)

      Path.join(template_dir, [namespace, ".json"])
      |> File.write!(Jason.encode!(data, pretty: true))
    end)
  end

  defp generate_suffix_keys(data) do
    Idiom.Plural.get_suffixes("en")
    |> Enum.map(fn suffix ->
      Map.update!(data, :key, &(&1 <> "_" <> suffix))
    end)
  end
end
