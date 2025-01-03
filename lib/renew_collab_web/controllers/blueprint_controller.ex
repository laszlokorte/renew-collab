defmodule RenewCollabWeb.BlueprintController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    documents = Renew.list_documents()
    render(conn, :index, documents: documents)
  end

  def primitives(conn, _params) do
    render(conn, :primitives)
  end
end
