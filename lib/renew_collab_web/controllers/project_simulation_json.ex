defmodule RenewCollabWeb.ProjectSimulationJSON do
  alias RenewCollabSim.Entities.Simulation
  use RenewCollabWeb, :verified_routes

  def index(%{project_id: project_id, simulations: simulations, runnings: runnings}) do
    %{
      href: url(~p"/api/projects/#{project_id}/simulations"),
      topic: "project-simulations:#{project_id}",
      content: index_content(%{simulations: simulations, runnings: runnings}),
      links: %{
        create: %{
          href: url(~p"/api/projects/#{project_id}/simulations"),
          method: "POST"
        },
        project: %{
          method: "GET",
          id: project_id,
          href: url(~p"/api/projects/#{project_id}")
        }
      }
    }
  end

  def index_content(%{simulations: simulations, runnings: runnings}) do
    document_ids_by_simulation =
      simulations
      |> Enum.map(& &1.id)
      |> RenewCollab.Renew.list_simulation_document_ids()

    %{
      items:
        for simulation <- simulations do
          list_data(simulation, runnings, Map.get(document_ids_by_simulation, simulation.id, []))
        end
    }
  end

  defp list_data(%Simulation{} = simulation, runnings, linked_document_ids) do
    %{
      href: url(~p"/api/simulations/#{simulation}"),
      id: simulation.id,
      label: simulation_label(simulation),
      inserted_at: simulation.inserted_at,
      updated_at: simulation.updated_at,
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
          end,
        document_ids: document_ids(simulation, linked_document_ids)
      }
    }
  end

  defp simulation_label(%Simulation{} = simulation) do
    main_net_name =
      case simulation.shadow_net_system do
        %{main_net_name: name} when is_binary(name) and name != "" -> name
        _ -> "Untitled"
      end

    "#{main_net_name}[0]"
  end

  defp document_ids(%Simulation{document_links: %Ecto.Association.NotLoaded{}}, fallback),
    do: fallback

  defp document_ids(%Simulation{document_links: links}, _fallback) when is_list(links) do
    links
    |> Enum.map(& &1.document_id)
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  defp document_ids(_simulation, fallback), do: fallback
end
