defmodule RenewCollabWeb.ApiJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{}) do
    %{
      routes: %{
        auth: %{
          method: "POST",
          href: url(~p"/api/auth")
        },
        backend: %{
          method: "GET",
          href: url(~p"/")
        },
        projects: %{
          method: "GET",
          href: url(~p"/api/projects")
        },
        project: %{
          method: "GET",
          href: url(~p"/api/projects/:id")
        },
        document: %{
          method: "GET",
          href: url(~p"/api/documents/:id")
        },
        simulation: %{
          method: "GET",
          href: url(~p"/api/simulations/:id")
        },
        formalisms: %{
          method: "GET",
          href: url(~p"/api/formalisms")
        },
        syntax: %{
          method: "GET",
          href: url(~p"/api/syntax")
        },
        upload_svg: %{
          method: "POST",
          href: url(~p"/api/media/svg")
        },
        live_socket: %{
          method: "GET",
          href:
            static_url(RenewCollabWeb.Endpoint, "/redux")
            |> String.replace_leading("http", "ws")
        }
      }
    }
  end
end
