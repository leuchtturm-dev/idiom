defmodule Idiom.MixProject do
  use Mix.Project

  def project do
    [
      app: :idiom,
      description: "Modern internationalization library",
      version: "0.3.1",
      elixir: "~> 1.13",
      compilers: Mix.compilers() ++ [:leex, :yecc],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:decimal, "~> 2.1"},
      {:jason, "~> 1.0"},
      {:req, "~> 0.3"},
      {:uniq, "~> 0.6"},
      {:nimble_options, "~> 1.0"},
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.30", only: :dev},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.17", only: :test}
    ]
  end

  defp package do
    [
      name: "idiom",
      licenses: ["WTFPL"],
      maintainers: ["Christoph Schmatzler"],
      links: %{"GitHub" => "https://github.com/cschmatzler/idiom"}
    ]
  end

  defp docs do
    [
      main: "Idiom",
      extras: ["Cheatsheet.cheatmd"]
    ]
  end
end
