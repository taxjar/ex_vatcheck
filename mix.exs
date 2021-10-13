defmodule ExVatcheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_vatcheck,
      version: "0.2.1",
      elixir: "~> 1.6",
      name: "ExVatcheck",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "An Elixir package for verifying VAT identification numbers.",
      source_url: "https://github.com/taxjar/ex_vatcheck",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        credo: :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.3"},
      {:sweet_xml, "~> 0.7"},
      # dev/test/tools
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:mimic, "~> 0.2", only: :test}
    ]
  end

  defp docs do
    [
      main: "ExVatcheck"
    ]
  end

  defp package do
    [
      files: ["lib", "LICENSE", "mix.exs", "README.md"],
      maintainers: ["TaxJar"],
      licenses: ["MIT"],
      links: %{
        "github" => "https://github.com/taxjar/ex_vatcheck"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/fixtures"]
  defp elixirc_paths(_), do: ["lib"]
end
