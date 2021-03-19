defmodule ExVatcheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_vatcheck,
      version: "0.1.5",
      elixir: "~> 1.4",
      name: "ExVatcheck",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "An Elixir package for verifying VAT identification numbers.",
      source_url: "https://github.com/taxjar/ex_vatcheck",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        credo: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
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
      {:sweet_xml, "~> 0.6"},
      # dev/test/tools
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: [:test]},
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
