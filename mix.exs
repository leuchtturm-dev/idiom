defmodule Idiom.MixProject do
  use Mix.Project

  def project do
    [
      app: :idiom,
      description: "Modern internationalization library",
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end

  defp package do
    [
      name: "idiom",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cschmatzler/idiom"}
    ]
  end
end
