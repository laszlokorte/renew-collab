defmodule RenewCollabWeb.ReduxDocumentChannel do
  use RenewCollabWeb.StateChannel, :redux

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_document:" <> document_id, _params, socket) do
    case RenewCollab.Renew.get_document_with_elements(document_id) do
      nil ->
        {:error, %{reason: "not found"}}

      doc ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "document:#{document_id}")

        account_id = socket.assigns.current_account.account_id
        username = socket.assigns.current_account.username
        connection_id = socket.assigns.connection_id

        Presence.track(socket, account_id, %{
          online_at: inspect(System.system_time(:second)),
          username: username,
          connection_id: connection_id,
          color: make_color(account_id),
          cursor: nil
        })

        push(socket, "presence_state", Presence.list(socket))

        {:ok, RenewCollabWeb.DocumentJSON.show_content(doc),
         assign(socket, :document_id, document_id)}
    end
  end

  @impl true
  def handle_message({:document_changed, document_id}, _state) do
    {:noreply,
     RenewCollabWeb.DocumentJSON.show_content(
       RenewCollab.Renew.get_document_with_elements(document_id)
     )}
  end

  @impl true
  def handle_event("cursor", %{"x" => x, "y" => y}, _state, socket) do
    account_id = socket.assigns.current_account.account_id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        cursor: %{x: x, y: y}
      })
    )

    :silent
  end

  @impl true
  def handle_event("cursor", %{}, _state, socket) do
    account_id = socket.assigns.current_account.account_id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        cursor: nil
      })
    )

    :silent
  end

  @impl true
  def handle_event("select", %{}, _state, socket) do
    account_id = socket.assigns.current_account.account_id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        selection: nil
      })
    )

    :silent
  end

  @impl true
  def handle_event("select", layer_id, _state, socket) when is_binary(layer_id) do
    account_id = socket.assigns.current_account.account_id

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        selection: layer_id
      })
    )

    :silent
  end

  @impl true
  def handle_event(
        "create_layer",
        %{"pos" => %{"x" => cx, "y" => cy}, "shape_id" => shape_id},
        %{},
        socket
      ) do
    RenewCollab.Commands.CreateLayer.new(%{
      document_id: socket.assigns.document_id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.RectangleFigure",
        "box" => %{
          "position_x" => cx - 25,
          "position_y" => cy - 25,
          "width" => 50,
          "height" => 50,
          "symbol_shape_id" => shape_id
        }
      }
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  @impl true
  def handle_event(
        "create_layer",
        %{"points" => points},
        %{},
        socket
      )
      when is_list(points) and length(points) > 1 do
    %{"x" => source_x, "y" => source_y} = Enum.at(points, 0)
    %{"x" => target_x, "y" => target_y} = Enum.at(points, -1)

    RenewCollab.Commands.CreateLayer.new(%{
      document_id: socket.assigns.document_id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.PolyLineFigure",
        "edge" => %{
          "source_x" => source_x,
          "source_y" => source_y,
          "target_x" => target_x,
          "target_y" => target_y,
          "waypoints" =>
            points
            |> Enum.drop(1)
            |> Enum.drop(-1)
            |> Enum.with_index()
            |> Enum.map(fn {%{"x" => x, "y" => y}, sort} ->
              %{
                position_x: x,
                position_y: y,
                sort: sort
              }
            end)
        }
      }
    })
    |> RenewCollab.Commander.run_document_command()

    :silent
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
