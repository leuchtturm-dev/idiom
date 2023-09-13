defmodule Mix.Tasks.Idiom.Extract do
  @moduledoc false
  use Mix.Task

  @switches [
    base_locale: :string,
    data_dir: :string,
    default_namespace: :string,
    files: :string,
    merge: :boolean
  ]

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, switches: @switches)

    base_locale =
      Keyword.get(opts, :base_locale) ||
        raise ArgumentError, """
        Base locale has not been set. Please pass the `--base-locale` option.
        """

    Idiom.Extract.start_link()
    Application.put_env(:idiom, :extracting?, true)

    Mix.Task.clear()
    Mix.Task.run("compile", ["--force"])

    base_dir =
      Keyword.get(opts, :data_dir) ||
        Application.get_env(:idiom, :data_dir) ||
        "priv/idiom"

    template_dir = Path.join(base_dir, "template_#{base_locale}")
    File.mkdir_p!(template_dir)

    default_namespace =
      Keyword.get(opts, :default_namespace) || Idiom.get_namespace() ||
        raise ArgumentError, """
        No default namespace set. Please pass the `---default-namespace` locale or add a default namespace to your `config.exs`.
        """

    Idiom.Extract.keys()
    |> Enum.filter(fn %{file: file} -> included?(file, opts) end)
    |> Enum.map(fn
      %{has_count?: true, plural_type: plural_type} = data ->
        generate_suffix_keys(data, base_locale, plural_type)

      key ->
        key
    end)
    |> List.flatten()
    |> Enum.group_by(fn
      %{namespace: nil} -> default_namespace
      %{namespace: namespace} -> namespace
    end)
    |> Enum.map(fn {namespace, data} ->
      data =
        data
        |> Enum.reduce(%{}, fn %{key: key}, acc -> Map.put(acc, key, key) end)
        |> Jason.encode!(pretty: true)

      template_dir
      |> Path.join([namespace, ".json"])
      |> File.write!(data)
    end)
  end

  defp included?(file, opts) do
    opts
    |> Keyword.get(:files, "lib/**")
    |> Path.wildcard()
    |> Enum.map(&Path.expand/1)
    |> Enum.member?(file)
  end

  defp generate_suffix_keys(data, locale, plural_type) do
    locale
    |> Idiom.Plural.get_suffixes(plural_type)
    |> Enum.map(fn suffix ->
      Map.update!(data, :key, &(&1 <> "_" <> suffix))
    end)
  end
end
