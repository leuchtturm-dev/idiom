defmodule Mix.Tasks.Idiom.Extract do
  @moduledoc """
  Extracts keys into a template directory that can be used for localisation.

  ## Setup

  In order to be able to extract keys, this task will hook into the compilation step. Since only macro calls are expanded at compile time, calls to `Idiom.t/3`
  directly will not work. To work around this, Idiom includes a `__using__/1` macro that exposes the same API while at the same time making calls available
  at compile time.

  If you are just getting started with Idiom, setting this up is easy: create a new module, for example `Project.Localisation` and `use Idiom` in it:

  ```elixir
  defmodule Project.Localisation do
    use Idiom
  end
  ```

  Then, you can just `import Project.Localisation` and use `t/3` as in the documentation for Idiom.

  If you are currently directly calling `t/3` without `use`-ing Idiom, create the same module and in addition replace your `import Idiom` calls with
  `import Project.Localisation`. Afterwards, your keys will be available to `mix idiom.extract`.

  ## Arguments

  - `--base-locale` (required): Sets the base locale of the template.  
  - `--data-dir`: Directory to extract template to. Will default to the `data_dir` configuration setting, or `priv/idiom` if neither command-line option nor 
    setting exist.  
  - `--default-namespace`: Default namespace. When the `idiom.extract` tasks finds a call to `Idiom.t/3` that passes `namespace` explicitly, it will be used 
    for extractions. For situations where the namespace is not set explicitly but through `Idiom.put_namespace/1`, you can set the namespace to extract to 
    using this option.  
  - `--files`: Filters files to extract. When using the `default-namespace`, you will probably only want to extract keys from specific modules which can be
    selected using this option. Accepts everything that `Path.wildcard/1` accepts.

  ## Examples

  ```bash
  # Extract all keys with English as base
  mix idiom.extract --base-locale en

  # Extract all keys in the "signup" folder and add them to the "singup" namespace
  mix idiom.extract --base-locale en --default-namespace signup --files lib/project_web/live/signup/**
  ```
  """

  use Mix.Task

  @switches [
    base_locale: :string,
    data_dir: :string,
    default_namespace: :string,
    files: :string
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
