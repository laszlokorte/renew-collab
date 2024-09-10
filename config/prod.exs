import Config

# Do not print debug messages in production
config :logger, level: :info

config :renew_collab, RenewCollab.Repo, adapter: Ecto.Adapters.MyXQL
# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
