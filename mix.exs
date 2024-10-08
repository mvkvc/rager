defmodule Rager.MixProject do
  use Mix.Project

  @name "Rager"
  @description "Tools for building with LLMs."
  @source_url "https://github.com/mvkvc/rager"
  @version "0.1.0"

  def project do
    [
      app: :rager,
      name: @name,
      description: @description,
      source_url: @source_url,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      dialyzer: dialyzer(),
      docs: docs(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "plts",
      plt_file: {:no_warn, "plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      extras: [{:"README.md", [title: "Overview"]}],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:ecto, "~> 3.12"},
      #
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      doc: ["docs --formatter html"],
      lint: [
        "format --check-formatted --no-exit",
        "credo",
        "dialyzer"
      ]
    ]
  end
end
