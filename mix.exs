defmodule RenewCollab.MixProject do
  use Mix.Project

  def project do
    [
      app: :renew_collab,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {RenewCollab.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:myxql, "~> 0.7.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:corsica, "~> 2.0"},
      {:live_state, "~> 0.7"},
      {:pbkdf2_elixir, "~> 2.2"},
      {:renewex, "~> 0.14.0"},
      {:renewex_iconset, "~> 0.2.0"},
      {:renewex_routing, "~> 0.2.0"},
      {:renewex_converter, "~> 0.4.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild renew_collab"],
      "assets.deploy": [
        "esbuild renew_collab --minify",
        "phx.digest"
      ]
    ]
  end
end
