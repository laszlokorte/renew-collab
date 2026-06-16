import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# Configure your database
config :renew_collab, RenewCollab.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_test.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

config :renew_collab, RenewCollabSim.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_sim_test.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool: Ecto.Adapters.SQL.Sandbox

config :renew_collab, RenewCollabAuth.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_auth_test.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

config :renew_collab, RenewCollabProj.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_proj_test.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

config :renew_collab, RenewCollab.TextMeasure.MeasureServer,
  script: "priv/text_metrics/TextMeasure.java"

config :renew_collab, :formalisms, [
  "P/T Net in Net Compiler",
  "Timed Java Compiler",
  "FA Automaton Compiler",
  "Bool Net Compiler",
  "FA Net Compiler",
  "Java Net Compiler",
  "P/T Net Compiler",
  "Single P/T Net with Channel Compiler",
  "Exception Catching Java Compiler",
  "CN Compiler"
]

config :renew_collab, :default_formalism, "P/T Net Compiler"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :renew_collab, RenewCollabWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ir+0OcDcRhukE7XErfwP+TyzjdhKB5L6OSlYfANnQTrlwFqA+15y69hoBosrjh6k",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
