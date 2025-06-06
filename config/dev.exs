import Config

config :renew_collab, :editor_url, "http://localhost:5173"

# Configure your database
config :renew_collab, RenewCollab.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_dev.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :renew_collab, RenewCollabSim.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_sim_dev.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :renew_collab, RenewCollabAuth.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_auth_dev.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :renew_collab, RenewCollabProj.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../renew_collab_proj_dev.db", __DIR__),
  pool_size: 1,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :renew_collab, RenewCollab.TextMeasure.MeasureServer,
  script: "priv/text_metrics/TextMeasure.java"

config :renew_collab, :formalisms, [
  "P/T Net Compiler",
  "P/T Net in Net Compiler",
  "Java Net Compiler",
  "Bool Net Compiler",
  "Timed Java Compiler",
  "Single P/T Net with Channel Compiler"
]

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :renew_collab, RenewCollabWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "T9rh3fGUvXs/CrmQv6Us79G7Ho4Ct/BQkIpia64YDmhq6eT0FkgL/qlCvOv5UxVc",
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/renew_collab_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :exqlite, make_force_build: false
config :exqlite, force_build: false

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

priv_path = Path.expand("../priv", __DIR__)

config :renew_collab, RenewCollabSim.Script.Runner,
  sim_renew_path: Path.join([priv_path, "simulation", "renew41"]),
  sim_interceptor_path: Path.join([priv_path, "simulation", "Interceptor.jar"]),
  sim_log_conf_path: Path.join([priv_path, "simulation", "log4j.properties"]),
  sim_xvbf_path: nil

# Enable dev routes for dashboard and mailbox
config :renew_collab, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
