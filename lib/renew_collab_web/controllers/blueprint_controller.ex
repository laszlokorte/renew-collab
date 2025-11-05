defmodule RenewCollabWeb.BlueprintController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollab.Primitives

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
    render(conn, :primitives, groups: Primitives.find_all())
  end
end
