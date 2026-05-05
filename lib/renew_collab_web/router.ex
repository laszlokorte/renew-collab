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

  pipeline :svg do
    plug :accepts, ["svg"]
  end

  pipeline :protected_api do
    plug :accepts, ["json"]
    plug :fetch_current_account_by_header
    plug :require_authenticated_account, false
  end

  if Application.compile_env(:renew_collab, :dev_routes) do
    pipeline :debug_protected_api do
      plug :fetch_session
      plug :accepts, ["json"]
      plug :debug_fetch_admin_account_by_header
      plug :require_authenticated_account, false
    end
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
  end

  scope "/api", RenewCollabWeb do
    # TODO: currently uploaded svg are not auth protected.
    # this is to allow them to be embeded via simple URL as <img> tag into documents
    # the API auth is based on Auth-Header (not cookies) but the header can not be set for simple
    # <img src=""> requests.
    # We could append auth tokens via ?query=param
    get "/media/svg/:id", MediaController, :show
  end

  scope "/api", RenewCollabWeb do
    if Application.compile_env(:renew_collab, :dev_routes) do
      pipe_through :debug_protected_api
    else
      pipe_through :protected_api
    end

    get "/symbols", SymbolController, :index
    get "/socket_schemas", SocketSchemaController, :index
    get "/semantic_tags", SemanticTagController, :index
    get "/syntax", SyntaxController, :list
    get "/syntax/:id", SyntaxController, :rules
    get "/primitives", BlueprintController, :primitives
    get "/blueprints", BlueprintController, :index

    scope "/documents" do
      get "/:id/export", DocumentController, :export
      get "/:id/download.iex", DocumentController, :inspect
      get "/:id/download.json", DocumentController, :show
      post "/:id/duplicate/:project_id", DocumentController, :duplicate
      get "/:id/simulations", SimulationLinksController, :index

      get "/:id", DocumentController, :show
      delete "/:id", DocumentController, :delete
      put "/:id", DocumentController, :update
      patch "/:id", DocumentController, :update
    end

    # post "project/:project_id/documents", DocumentController, :create
    # get "project/:project_id/documents", DocumentController, :index

    scope "/projects" do
      get "/", ProjectController, :index
      post "/", ProjectController, :create
      get "/:id", ProjectController, :show
      put "/:id", ProjectController, :update
      patch "/:id", ProjectController, :update
      delete "/:id", ProjectController, :delete

      get "/:id/export", ProjectController, :export

      get "/:project_id/members", ProjectMemberController, :index
      post "/:project_id/members", ProjectMemberController, :create
      get "/:project_id/documents", ProjectDocumentController, :index
      post "/:project_id/documents", ProjectDocumentController, :create
      get "/:project_id/simulations", ProjectSimulationController, :index
      post "/:project_id/simulations", ProjectSimulationController, :create

      get "/:project_id/blueprints", BlueprintController, :index

      post "/:project_id/documents/import", ProjectDocumentController, :import_documents
    end

    scope "/invitations" do
      get "/", InvitationController, :index
    end

    post "/projects/:project_id/media/svg", MediaController, :create

    scope "/simulations" do
      get "/:id", SimulationController, :show
      put "/:id", SimulationController, :update
      patch "/:id", SimulationController, :update
      delete "/:id", SimulationController, :delete
      get "/:id/instance/:net_name/:integer_id", SimulationController, :show_instance
      get "/:id/log", SimulationController, :log
      post "/:id/step", SimulationController, :step
      delete "/:id/process", SimulationController, :terminate
    end

    get "/formalisms", SimulationController, :formalisms

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
    pipe_through [:browser, :not_authenticated]
    get "/signup", SignupController, :new
    post "/signup", SignupController, :create
    get "/signup/:registration_id", SignupController, :waiting
    get "/signup/:registration_id/:confirmation_code", SignupController, :confirm
    post "/signup/:registration_id/:confirmation_code", SignupController, :set_password
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :not_authenticated]
    get "/account/reset", PasswordResetController, :new
    post "/account/reset", PasswordResetController, :create
    get "/account/reset/:reset_id/:confirmation_code", PasswordResetController, :confirm

    post "/account/reset/:reset_id/:confirmation_code",
         PasswordResetController,
         :reset_password
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated, :svg]

    get "/documents/:id/thumbnail", ThumbnailController, :thumbnail
    get "/documents/:id/thumbnail/:layer_id", ThumbnailController, :thumbnail
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated]

    delete "/logout", LoginController, :delete

    get "/", HomeController, :index

    get "/documents/:id/export", DocumentController, :export
    get "/projects/:id/export", ProjectController, :export
    get "/documents/:id/inspect", DocumentController, :inspect
    get "/shadow_net/:id/binary", ShadowNetController, :download
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated, :is_admin]

    get "/health", HealthController, :index
    get "/system", SystemController, :index
    post "/system/reset", SystemController, :reset
    post "/health/simulator", HealthController, :simulator
    get "/accounts", AccountsController, :index
    post "/accounts", AccountsController, :create
    delete "/accounts/:id", AccountsController, :delete
    post "/accounts/:id/admin", AccountsController, :admin
  end

  scope "/account/me", RenewCollabWeb do
    pipe_through [:browser, :authenticated]
    get "/", MyAccountController, :show
    post "/password", MyAccountController, :change_password
    delete "/", MyAccountController, :delete
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated]

    live_session :require_authenticated_user,
      on_mount: [
        {RenewCollabWeb.Auth, :ensure_authenticated}
      ] do
      live "/document/:id", LiveDocument
      live "/project/:project_id/documents", LiveDocuments
      live "/projects", LiveProjects
      live "/project/:project_id/settings", LiveProjectSettings
      live "/project/:project_id/shadow_nets", LiveShadowNets
      live "/project/:project_id/simulations", LiveSimulations
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
      live "/syntax", LiveSyntax
      live "/primitives", LivePrimitives
      live "/manage/projects", LiveProjectsManager
      live "/manage/project/:project_id", LiveProjectManager
      live "/manage/documents", LiveDocumentsManager
      live "/manage/simulations", LiveSimulationsManager
    end

    import Phoenix.LiveDashboard.Router

    live_dashboard "/phoenix-dashboard", metrics: RenewCollabWeb.Telemetry
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated, :is_admin]
  end
end
