defmodule RenewCollabWeb.Router do
  use RenewCollabWeb, :router

  import RenewCollabWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RenewCollabWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_account_by_header
  end

  pipeline :protected_api do
    plug :accepts, ["json"]
    plug :fetch_current_account_by_header
    plug :require_authenticated_account, false
  end

  pipeline :authenticated do
    plug :require_authenticated_account
  end

  pipeline :is_admin do
    plug :require_admin
  end

  pipeline :not_authenticated do
    plug :redirect_if_account_is_authenticated
  end

  scope "/api", RenewCollabWeb do
    pipe_through :api
    get "/", ApiController, :index
    post "/auth", ApiSessionController, :auth

    scope "/media" do
      get "/svg/:id", MediaController, :show
    end
  end

  scope "/api", RenewCollabWeb do
    if Application.compile_env(:renew_collab, :dev_routes) do
      pipe_through :api
    else
      pipe_through :protected_api
    end

    get "/symbols", SymbolController, :index
    get "/socket_schemas", SocketSchemaController, :index
    get "/semantic_tags", SemanticTagController, :index
    get "/semantic_rules", SemanticTagController, :rules
    get "/primitives", BlueprintController, :primitives
    get "/blueprints", BlueprintController, :index

    scope "/documents" do
      post "/import", DocumentController, :import
      get "/:id/export", DocumentController, :export
      get "/:id/download.iex", DocumentController, :inspect
      get "/:id/download.json", DocumentController, :show
      post "/:id/duplicate", DocumentController, :duplicate

      resources "/", DocumentController, except: [:new, :edit]
    end

    scope "/media" do
      post "/svg", MediaController, :create
    end

    scope "/simulations" do
      resources "/", SimulationController, except: [:new, :edit]
      get "/:id/instance/:net_name/:integer_id", SimulationController, :show_instance
      post "/:id/step", SimulationController, :step
      delete "/:id/process", SimulationController, :terminate
    end

    get "/shadow_net_system/:id", SimulationController, :show_sns
    get "/shadow_net_system/:id/download", ShadowNetController, :download
    post "/shadow_net_system/:id/simulate", ShadowNetController, :create_simulation
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :not_authenticated]

    get "/login", LoginController, :index
    post "/login", LoginController, :login
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated]

    delete "/logout", LoginController, :delete

    get "/", HomeController, :index

    get "/documents/:id/export", DocumentController, :export
    get "/documents/:id/inspect", DocumentController, :inspect
    get "/shadow_net/:id/binary", ShadowNetController, :download
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated, :is_admin]

    get "/health", HealthController, :index
    post "/health/simulator", HealthController, :simulator
    get "/accounts", AccountsController, :index
    post "/accounts", AccountsController, :create
    delete "/accounts/:id", AccountsController, :delete
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated]

    live_session :require_authenticated_user,
      on_mount: [
        {RenewCollabWeb.Auth, :ensure_authenticated}
      ] do
      live "/document/:id", LiveDocument
      live "/documents", LiveDocuments
      live "/shadow_nets", LiveShadowNets
      live "/shadow_net/:id", LiveShadowNet
      live "/simulation/:id", LiveSimulation
    end
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated, :is_admin]

    live_session :require_admin,
      on_mount: [
        {RenewCollabWeb.Auth, :ensure_authenticated},
        {RenewCollabWeb.Auth, :ensure_admin}
      ] do
      live "/socket_schemas", LiveSocketSchemas
      live "/socket_schema/:id", LiveSocketSchema
      live "/icons", LiveIcons
      live "/icon/:id", LiveIcon
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:renew_collab, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: RenewCollabWeb.Telemetry
    end
  end
end
