# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

defmodule DbAdapter do
  @choices %{
    "postgresql" => Ecto.Adapters.Postgres,
    "mysql" => Ecto.Adapters.MyXQL,
    "sqlite" => Ecto.Adapters.SQLite3,
    nil => Ecto.Adapters.SQLite3
  }

  def choose(env_name) do
    env_value = System.get_env(env_name)

    Map.get(@choices, env_value) || raise "Unknownm db adapter #{env_name}=#{env_value}"
  end
end

config :renew_collab, :app_titel, System.get_env("RENEW_APP_TITEL") || "Renew Web Editor (Dev)"

config :renew_collab, :db_adapter, DbAdapter.choose("RENEW_DOCS_DB_TYPE")
config :renew_collab, :db_auth_adapter, DbAdapter.choose("RENEW_ACCOUNT_DB_TYPE")
config :renew_collab, :db_sim_adapter, DbAdapter.choose("RENEW_SIM_DB_TYPE")

config :renew_collab,
  ecto_repos: [RenewCollab.Repo, RenewCollabSim.Repo, RenewCollabAuth.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :renew_collab, RenewCollab.Repo, priv: "priv/repo"

config :renew_collab, RenewCollabSim.Repo, priv: "priv/repo_sim"

config :renew_collab, RenewCollabAuth.Repo, priv: "priv/repo_auth"

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

config :exqlite, make_force_build: true
config :exqlite, force_build: true

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
