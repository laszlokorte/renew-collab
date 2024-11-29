defmodule RenewCollabWeb.ApiJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{}) do
    %{
      routes: %{
        auth: %{
          method: "POST",
          href: url(~p"/api/auth")
        },
        documents: %{
          method: "GET",
          href: url(~p"/api/documents")
        },
        import_documents: %{
          method: "POST",
          href: url(~p"/api/documents/import")
        },
        create_simulation: %{
          method: "POST",
          href: url(~p"/api/simulations")
        },
        simulations: %{
          method: "GET",
          href: url(~p"/api/simulations")
        },
        document: %{
          method: "GET",
          href: url(~p"/api/documents/:id")
        },
        simulation: %{
          method: "GET",
          href: url(~p"/api/simulations/:id")
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
