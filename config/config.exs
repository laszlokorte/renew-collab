# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :renew_collab, :db_adapter, Ecto.Adapters.SQLite3

config :renew_collab,
  ecto_repos: [RenewCollab.Repo, RenewCollabSim.Repo, RenewCollabAuth.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :renew_collab, RenewCollabWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: RenewCollabWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RenewCollab.PubSub,
  live_view: [signing_salt: "O8knBEdU"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :exqlite, make_force_build: false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  renew_collab: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :mime, :types, %{
  "application/custom+renew" => ["rnw"],
  "application/custom+aip" => ["aip"]
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
