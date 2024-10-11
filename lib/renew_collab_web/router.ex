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
  end

  pipeline :authenticated do
    plug :require_authenticated_account
  end

  pipeline :not_authenticated do
    plug :redirect_if_account_is_authenticated
  end

  scope "/api", RenewCollabWeb do
    pipe_through :api
    get "/", ApiController, :index
    post "/auth", ApiController, :auth
    get "/symbols", SymbolController, :index

    scope "/documents" do
      post "/import", DocumentController, :import
      get "/:id/export", DocumentController, :export
    end

    resources "/documents", DocumentController, except: [:new, :edit]
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
    get "/health", HealthController, :index
    get "/accounts", AccountsController, :index
    post "/accounts", AccountsController, :create
    delete "/accounts/:id", AccountsController, :delete

    get "/documents/:id/export", DocumentController, :export
    get "/documents/:id/inspect", DocumentController, :inspect
  end

  scope "/", RenewCollabWeb do
    pipe_through [:browser, :authenticated]

    live_session :require_authenticated_user,
      on_mount: [
        {RenewCollabWeb.Auth, :ensure_authenticated}
      ] do
      live "/document/:id", LiveDocument
      live "/documents", LiveDocuments
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
