defmodule RenewCollabWeb.SimulationLinksController do
  use RenewCollabWeb, :controller
  alias RenewCollab.Renew

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{"id" => document_id}) do
    render(conn, :index,
      document_id: document_id,
      links: Renew.list_simulation_links(document_id)
    )
  end
end
