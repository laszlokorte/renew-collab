defmodule RenewCollabWeb.SimulationJSON do
  alias RenewCollabSim.Entites.Simulation
  use RenewCollabWeb, :verified_routes

  def index(%{simulations: simulations, runnings: runnings}) do
    %{
      href: url(~p"/api/simulations"),
      topic: "redux_simulations",
      content: index_content(%{simulations: simulations, runnings: runnings}),
      links: %{
        create: %{
          href: url(~p"/api/simulations"),
          method: "POST"
        }
      }
    }
  end

  def formalisms(%{formalisms: formalisms}) do
    %{formalisms: formalisms |> Enum.map(&%{id: &1, label: &1})}
  end

  def created(%{simulation: simulation}) do
    %{id: simulation.id}
  end

  def show(%{simulation: simulation, running: running}) do
    detail_data(simulation, running)
  end

  def step(%{status: :ok = status}) do
    %{status: status}
  end

  def terminate(%{status: :ok = status}) do
    %{status: status}
  end

  defp detail_data(%Simulation{} = simulation, running) do
    %{
      # id: simulation.id,
      href: url(~p"/api/simulations/#{simulation}"),
      topic: "redux_simulation:#{simulation.id}",
      id: simulation.id,
      links: %{
        log: %{
          href: url(~p"/api/simulations/#{simulation}/log"),
          method: "GET"
        },
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
        symbols: %{
          href: url(~p"/api/symbols"),
          method: "GET"
        },
        socket_schemas: %{
          href: url(~p"/api/socket_schemas"),
          method: "GET"
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
      content: show_content(simulation, running, nil)
    }
  end

  def show_content(%Simulation{} = simulation, running, is_playing) do
    %{
      timestep: simulation.timestep,
      running: running,
      name: simulation.id,
      is_playing: is_playing,
      net_instances: Enum.map(simulation.net_instances, &list_instance/1),
      shadow_net_system: show_sns_item(simulation.shadow_net_system)
    }
  end

  def show_instance(%{net_instance: net_instance}) do
    %{
      href:
        url(
          ~p"/api/simulations/#{net_instance.simulation_id}/instance/#{net_instance.shadow_net.name}/#{net_instance.integer_id}"
        ),
      id: net_instance.id,
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
          ~p"/api/simulations/#{net_instance.simulation_id}/instance/#{net_instance.shadow_net.name}/#{net_instance.integer_id}"
        ),
      topic: "redux_net_instance:#{net_instance.id}",
      id: net_instance.id,
      label: net_instance.label,
      links: %{
        shadow_net: %{
          href: url(~p"/api/shadow_net_system/#{net_instance.shadow_net_id}"),
          id: net_instance.shadow_net_id
        }
      }
    }
  end

  def show_instance_content(net_instance) do
    %{
      id: net_instance.id,
      shadow_net_id: net_instance.shadow_net_id,
      tokens: Enum.map(net_instance.tokens, &show_token/1),
      firings: Enum.map(net_instance.firings, &show_firing/1),
      label: net_instance.label,
      integer_id: net_instance.integer_id
    }
  end

  defp show_sns_item(sns) do
    %{
      "href" => url(~p"/api/shadow_net_system/#{sns.id}"),
      "content" => %{
        "main_net_name" => sns.main_net_name,
        "nets" => Enum.map(sns.nets, &%{"id" => &1.id, "name" => &1.name})
      }
    }
  end

  def show_sns(%{sns: sns}) do
    %{
      "id" => sns.id,
      "href" => url(~p"/api/shadow_net_system/#{sns.id}"),
      "content" => %{
        "main_net_name" => sns.main_net_name,
        "nets" =>
          Enum.map(sns.nets, &%{"id" => &1.id, "name" => &1.name, "document" => net_document(&1)})
      }
    }
  end

  defp net_document(%{document_json: json}) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, j = %{}} -> j
      _ -> nil
    end
  end

  defp net_document(%{document_json: nil}), do: nil

  defp show_token(net_token) do
    %{place_id: net_token.place_id, id: net_token.id, value: net_token.value}
  end

  defp show_firing(firing) do
    %{transition_id: firing.transition_id, id: firing.id, timestep: firing.timestep}
  end

  def index_content(%{simulations: simulations, runnings: runnings}) do
    %{
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

  def log(%{simulation_id: simulation_id, log_entries: log_entries}) do
    %{
      href: url(~p"/api/simulations/#{simulation_id}"),
      topic: "redux_simulation_log:#{simulation_id}",
      content: show_log_content(log_entries)
    }
  end

  def show_log_content(log_entries) do
    %{
      log_entries:
        log_entries
        |> Enum.map(fn log ->
          %{content: log.content}
        end)
    }
  end
end
