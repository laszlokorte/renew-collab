defmodule RenewCollabWeb.ProjectSimulationJSON do
  alias RenewCollabSim.Entites.Simulation
  use RenewCollabWeb, :verified_routes

  def index(%{project_id: project_id, simulations: simulations, runnings: runnings}) do
    %{
      href: url(~p"/api/simulations"),
      topic: "project/fooo/simulations",
      content:
        index_content(%{project_id: project_id, simulations: simulations, runnings: runnings}),
      links: %{
        create: %{
          href: url(~p"/api/simulations"),
          method: "POST"
        }
      }
    }
  end

  def index_content(%{project_id: project_id, simulations: simulations, runnings: runnings}) do
    %{
      project_id: project_id,
      items: for(simulation <- simulations, do: list_data(simulation, runnings))
    }
  end

  defp list_data(%Simulation{} = simulation, runnings) do
    %{
      href: url(~p"/api/simulations/#{simulation}"),
      id: simulation.id,
      label: simulation.shadow_net_system.main_net_name,
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
        },
        shadow_net_compiled: %{
          href: url(~p"/api/shadow_net_system/#{simulation.shadow_net_system_id}/download"),
          method: "GET"
        },
        duplicate: %{
          href: url(~p"/api/shadow_net_system/#{simulation.shadow_net_system_id}/simulate"),
          method: "POST"
        }
      },
      content: %{
        timestep: simulation.timestep,
        running:
          case runnings do
            nil -> nil
            map -> MapSet.member?(map, simulation.id)
          end
      }
    }
  end
end
