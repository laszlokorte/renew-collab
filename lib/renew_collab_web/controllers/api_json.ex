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
        document: %{
          method: "GET",
          href: url(~p"/api/documents/:id")
        },
        live_socket: %{
          method: "GET",
          href: url(~p"/redux") |> String.replace_leading("http", "ws")
        }
      }
    }
  end

  def auth(%{}) do
    %{}
  end
end
