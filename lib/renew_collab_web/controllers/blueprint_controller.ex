defmodule RenewCollabWeb.BlueprintController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew
  alias RenewCollab.Primitives

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    documents = Renew.list_documents()
    render(conn, :index, documents: documents)
  end

  def primitives(conn, _params) do
    render(conn, :primitives, groups: Primitives.find_all())
  end
end
