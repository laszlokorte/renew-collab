defmodule RenewCollabWeb.BlueprintController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{"project_id" => project_id}) do
    documents =
      %Views.ProjectDocumentsList{
        project_id: project_id
      }
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :index, documents: documents)
  end

  def index(conn, _params) do
    documents = []
    render(conn, :index, documents: documents)
  end

  def primitives(conn, _params) do
    groups =
      %Views.GlobalPrimitives{}
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :primitives, groups: groups)
  end
end
