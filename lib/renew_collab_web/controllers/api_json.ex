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
        document: %{
          method: "GET",
          href: url(~p"/api/documents/:id")
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
