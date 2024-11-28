defmodule RenewCollabWeb.SimulationJSON do
  alias RenewCollabSim.Entites.Simulation
  use RenewCollabWeb, :verified_routes

  def index(%{simulations: simulations}) do
    %{
      href: url(~p"/api/simulations"),
      topic: "redux_documents",
      content: index_content(%{simulations: simulations}),
      links: %{
        create: %{
          href: url(~p"/api/simulations"),
          method: "POST"
        }
      }
    }
  end

  def show(%{simulation: simulation}) do
    detail_data(simulation)
  end

  def step(%{status: :ok = status}) do
    %{status: status}
  end

  def terminate(%{status: :ok = status}) do
    %{status: status}
  end

  defp detail_data(%Simulation{} = simulation) do
    %{
      # id: simulation.id,
      href: url(~p"/api/simulations/#{simulation}"),
      topic: "redux_simulation:#{simulation.id}",
      id: simulation.id,
      links: %{
        step: %{
          href: url(~p"/api/simulations/#{simulation}/step"),
          method: "POST"
        },
        terminate: %{
          href: url(~p"/api/simulations/#{simulation}/process"),
          method: "DELETE"
        },
        delete: %{
          href: url(~p"/api/simulations/#{simulation}"),
          method: "DELETE"
        }
      },
      content: show_content(simulation)
    }
  end

  def show_content(%Simulation{} = simulation) do
    %{
      timestep: simulation.timestep,
      net_instances: Enum.map(simulation.net_instances, &list_instance/1)
    }
  end

  def show_instance(%{net_instance: net_instance}) do
    %{
      href:
        url(
          ~p"/api/simulations/#{net_instance.simulation_id}/#{net_instance.shadow_net.name}/#{net_instance.integer_id}"
        ),
      links: %{
        simulation: %{
          href: url(~p"/api/simulations/#{net_instance.simulation_id}")
        }
      },
      content: show_instance_content(net_instance)
    }
  end

  def list_instance(net_instance) do
    %{
      href:
        url(
          ~p"/api/simulations/#{net_instance.simulation_id}/#{net_instance.shadow_net.name}/#{net_instance.integer_id}"
        ),
      label: net_instance.label
    }
  end

  def show_instance_content(net_instance) do
    %{
      shadow_net_id: net_instance.shadow_net_id,
      tokens: Enum.map(net_instance.tokens, &show_token/1),
      label: net_instance.label,
      integer_id: net_instance.integer_id
    }
  end

  defp show_token(net_token) do
    %{id: net_token.id, value: net_token.value}
  end

  def index_content(%{simulations: simulations}) do
    %{
      items: for(simulation <- simulations, do: list_data(simulation))
    }
  end

  defp list_data(%Simulation{} = simulation) do
    %{
      # id: document.id,
      href: url(~p"/api/simulations/#{simulation}"),
      id: simulation.id,
      links: %{
        step: %{
          href: url(~p"/api/simulations/#{simulation}/step"),
          method: "POST"
        },
        terminate: %{
          href: url(~p"/api/simulations/#{simulation}/process"),
          method: "DELETE"
        },
        delete: %{
          href: url(~p"/api/simulations/#{simulation}"),
          method: "DELETE"
        }
      },
      content: %{
        timestep: simulation.timestep
      }
    }
  end
end
