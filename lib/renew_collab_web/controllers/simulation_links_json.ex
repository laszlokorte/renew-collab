defmodule RenewCollabWeb.SimulationLinksJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{document_id: document_id, links: simulations}) do
    %{
      topic: "redux_simulation_links:#{document_id}",
      content: index_content(%{links: simulations})
    }
  end

  def index_content(%{links: simulations}) do
    %{
      items:
        for l <- simulations do
          %{
            id: l.simulation_id,
            href: url(~p"/api/simulations/#{l.simulation_id}")
          }
        end
    }
  end
end
