import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/renew_collab start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :renew_collab, RenewCollabWeb.Endpoint, server: true
end

maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

if config_env() == :prod do
  read_db_config = fn adapter, prefix ->
    case adapter do
      Ecto.Adapters.SQLite3 ->
        [
          pool_size: 1,
          database: System.get_env("#{prefix}_PATH") || raise("#{prefix}_PATH is missing")
        ]

      Ecto.Adapters.Postgres ->
        db_url = System.get_env("#{prefix}_URL")
        socket_dir = System.get_env("#{prefix}_SOCKET_DIR")
        pool_size = System.get_env("#{prefix}_POOL_SIZE") || 10

        if socket_dir do
          [
            pool_size: pool_size,
            socket_dir: socket_dir,
            username: System.get_env("#{prefix}_USER") || raise("#{prefix}_USER is missing"),
            password:
              System.get_env("#{prefix}_PASSWORD") ||
                raise("#{prefix}_PASSWORD is missing"),
            database:
              System.get_env("#{prefix}_DATABASE") ||
                raise("#{prefix}_DATABASE is missing")
          ]
        else
          [
            pool_size: pool_size,
            url: db_url || raise("#{prefix}_URL is missing")
          ]
        end

      Ecto.Adapters.MyXQL ->
        db_url = System.get_env("#{prefix}_URL")
        socket = System.get_env("#{prefix}_SOCKET")
        pool_size = System.get_env("#{prefix}_POOL_SIZE") || 10

        if socket do
          [
            pool_size: pool_size,
            socket: socket,
            username: System.get_env("#{prefix}_USER") || raise("#{prefix}_USER is missing"),
            password:
              System.get_env("#{prefix}_PASSWORD") ||
                raise("#{prefix}_PASSWORD is missing"),
            database:
              System.get_env("#{prefix}_DATABASE") ||
                raise("#{prefix}_DATABASE is missing")
          ]
        else
          [
            pool_size: pool_size,
            url: db_url || raise("#{prefix}_URL is missing")
          ]
        end

      _ ->
        raise "Unexpected adapter for #{prefix}"
    end
  end

  config :renew_collab,
         RenewCollab.Repo,
         [
           adapter: Application.compile_env(:renew_collab, :db_adapter),
           stacktrace: false,
           show_sensitive_data_on_connection_error: false
         ]
         |> Keyword.merge(
           read_db_config.(Application.compile_env(:renew_collab, :db_adapter), "RENEW_DOCS_DB")
         )

  config :renew_collab,
         RenewCollabAuth.Repo,
         [
           adapter: Application.compile_env(:renew_collab, :db_auth_adapter),
           stacktrace: false,
           show_sensitive_data_on_connection_error: false
         ]
         |> Keyword.merge(
           read_db_config.(
             Application.compile_env(:renew_collab, :db_auth_adapter),
             "RENEW_ACCOUNT_DB"
           )
         )

  config :renew_collab,
         RenewCollabSim.Repo,
         [
           adapter: Application.compile_env(:renew_collab, :db_sim_adapter),
           stacktrace: false,
           show_sensitive_data_on_connection_error: false
         ]
         |> Keyword.merge(
           read_db_config.(
             Application.compile_env(:renew_collab, :db_sim_adapter),
             "RENEW_SIM_DB"
           )
         )

  config :renew_collab,
         RenewCollabProj.Repo,
         [
           adapter: Application.compile_env(:renew_collab, :db_proj_adapter),
           stacktrace: false,
           show_sensitive_data_on_connection_error: false
         ]
         |> Keyword.merge(
           read_db_config.(
             Application.compile_env(:renew_collab, :db_proj_adapter),
             "RENEW_PROJ_DB"
           )
         )

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || raise "PHX_HOST IS MISSING"
  is_local = host == "localhost"

  port = String.to_integer(System.get_env("PORT") || "4000")
  external_port = String.to_integer(System.get_env("PORT_EXTERNAL") || "#{port}")

  config :renew_collab, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :renew_collab, RenewCollabWeb.Endpoint,
    url: [host: host, port: external_port, scheme: if(is_local, do: "http", else: "https")],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :renew_collab, RenewCollabSim.Script.Runner,
    sim_renew_path: System.get_env("SIM_RENEW_PATH") || raise("SIM_RENEW_PATH is missing"),
    sim_interceptor_path:
      System.get_env("SIM_STDIO_WRAPPER") || raise("SIM_STDIO_WRAPPER is missing"),
    sim_log_conf_path: System.get_env("SIM_LOG4J_CONF") || raise("SIM_LOG4J_CONF is missing"),
    sim_xvbf_path: System.get_env("SIM_XVBF") || nil,
    sim_xvbf_display: System.get_env("SIM_XVBF_DISPLAY") || nil

  config :renew_collab, RenewCollabSim.Commands,
    sim_start: System.get_env("SIM_RENEW_CMD_START") || "startsimulation",
    sim: System.get_env("SIM_RENEW_CMD") || "simulation",
    sim_step: System.get_env("SIM_RENEW_CMD_STEP") || "step",
    set_formalism: System.get_env("SIM_RENEW_CMD_SETFORMALISM") || "setFormalism",
    export: System.get_env("SIM_RENEW_CMD_EXPORT") || "ex",
    ssn: System.get_env("SIM_RENEW_CMD_SSN") || "ShadowNetSystem"

  config :renew_collab, RenewCollab.TextMeasure.MeasureServer,
    script: System.get_env("RENEW_TEXT_MEASURE") || raise("RENEW_TEXT_MEASURE is missing")

  ssl_key_path = System.get_env("RENEW_SSL_KEY_PATH")
  ssl_cert_path = System.get_env("RENEW_SSL_CERT_PATH")
  ssl_port = String.to_integer(System.get_env("SSL_PORT") || "443")

  if ssl_key_path && ssl_cert_path do
    config :renew_collab, RenewCollabWeb.Endpoint,
      https: [
        port: ssl_port,
        cipher_suite: :strong,
        keyfile: ssl_key_path,
        certfile: ssl_cert_path
      ]

    config :renew_collab, RenewCollabWeb.Endpoint, force_ssl: [hsts: true]
  end

  app_title = System.get_env("RENEW_APP_TITEL")

  if app_title do
    config :renew_collab, :app_titel, app_title
  end

  editor_url = System.get_env("RENEW_EDITOR_URL")

  if editor_url do
    config :renew_collab, :editor_url, editor_url
  end

  config :renew_collab,
         :formalisms,
         (System.get_env("RENEW_FORMALISMS") || "")
         |> String.split(";")
         |> Enum.map(&String.trim/1)
         |> Enum.filter(&(&1 != ""))

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :renew_collab, RenewCollabWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :renew_collab, RenewCollabWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
