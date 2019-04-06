defmodule ExVatcheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_vatcheck,
      version: "0.1.0",
      elixir: "~> 1.4",
      name: "ExVatcheck",
      description: "An Elixir package for verifying VAT identification numbers.",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:httpoison, "~> 1.5.0"},
      {:mimic, "~> 0.2", only: :test},
      {:sweet_xml, "~> 0.6.6"}
    ]
  end
end
