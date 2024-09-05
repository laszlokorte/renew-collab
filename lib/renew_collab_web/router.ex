defmodule RenewCollabWeb.Router do
  use RenewCollabWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug RenewCollabWeb.Plug.Authenticate
  end

  scope "/api", RenewCollabWeb do
    pipe_through :api
    post "/auth/login", SessionController, :new
  end

  scope "/api", RenewCollabWeb do
    pipe_through [:api, :authenticated]

    scope "/documents" do
      post "/import", DocumentController, :import
    end

    resources "/documents", DocumentController, except: [:new, :edit] do
      resources "/elements", ElementController, only: [:index, :create, :show]
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
