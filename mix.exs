defmodule RealtimePesaguard.MixProject do
  use Mix.Project

  def project do
    [
      app: :realtime_pesaguard,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {RealtimePesaguard.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_pubsub, "~> 2.1"},
      {:bandit, "~> 1.5"},
      {:plug_cowboy, "~> 2.7", only: :test},
      {:jason, "~> 1.4"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      {:joken, "~> 2.6"},
      {:finch, "~> 0.18"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": []
    ]
  end
end
