defmodule RenewCollabWeb.ReduxSimulationLinksChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollab.Renew

  @impl true
  def init("redux_simulation_links:" <> document_id, _params, socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "document:#{document_id}")

    {:ok,
     RenewCollabWeb.SimulationLinksJSON.index_content(%{
       links: Renew.list_simulation_links(document_id)
     })}
  end

  @impl true
  def handle_message({:document_simulated, document_id}, _state) do
    {:noreply,
     RenewCollabWeb.SimulationLinksJSON.index_content(%{
       links: Renew.list_simulation_links(document_id)
     })}
  end
end
