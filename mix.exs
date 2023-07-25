defmodule Idiom.MixProject do
  use Mix.Project

  def project do
    [
      app: :idiom,
      description: "Modern internationalization library",
      version: "0.1.4",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
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
      {:tesla, "~> 1.7"},
      {:finch, "~> 0.16"},
      {:jason, "~> 1.0"},
      {:decimal, "~> 2.1"},
      {:credo, "~> 1.7", only: :dev},
      {:ex_doc, "~> 0.30.2", only: :dev}
    ]
  end

  defp package do
    [
      name: "idiom",
      licenses: ["MIT"],
      maintainers: ["Christoph Schmatzler"],
      links: %{"GitHub" => "https://github.com/cschmatzler/idiom"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
