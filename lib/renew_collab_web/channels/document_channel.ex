defmodule RenewCollabWeb.DocumentChannel do
  use RenewCollabWeb, :channel

  alias RenewCollab.Renew
  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Element

  use Phoenix.VerifiedRoutes,
    router: RenewCollabWeb.Router,
    endpoint: RenewCollabWeb.Endpoint

  @impl true
  def join("document:" <> documet_id, payload, socket) do
    if authorized?(documet_id, payload) do
      {:ok, assign(socket, :document_id, documet_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    # {:noreply, socket}
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("create_element", %{"element" => element_params}, socket) do
    with {:ok, %Element{} = element} <-
           Renew.create_element(%Document{id: socket.assigns.document_id}, element_params) do
      broadcast!(
        socket,
        "element:new",
        Map.take(element, [:id, :z_index, :position_x, :position_y])
      )
    else
      err -> dbg(err)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_in(
        "draw_line",
        %{"element" => %{"z_index" => z_index, "points" => [first_point | _] = points}},
        socket
      ) do
    with {:ok, %Element{} = element} <-
           Renew.create_element(%Document{id: socket.assigns.document_id}, %{
             "z_index" => z_index,
             "position_x" => Map.get(first_point, "x"),
             "position_y" => Map.get(first_point, "y"),
             "connection" => %{
               "source_x" => Map.get(first_point, "x"),
               "source_y" => Map.get(first_point, "y"),
               "target_x" => Map.get(List.last(points), "x"),
               "target_y" => Map.get(List.last(points), "y"),
               "waypoints" =>
                 points
                 |> Enum.drop(1)
                 |> Enum.drop(-1)
                 |> Enum.with_index()
                 |> Enum.map(fn {p, index} ->
                   dbg(p)

                   %{
                     "sort" => index,
                     "position_x" => Map.get(p, "x"),
                     "position_y" => Map.get(p, "y")
                   }
                 end)
             }
           }) do
      broadcast!(socket, "element:new", RenewCollabWeb.DocumentJSON.element_data(element))
    else
      err -> dbg(err)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_in(_, payload, socket) do
    {:noreply, socket}
    # {:noreply, socket}
    # {:reply, {:ok, payload}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(documet_id, _payload) do
    with %RenewCollab.Document.Document{} <- RenewCollab.Renew.get_document!(documet_id) do
      true
    else
      _ -> false
    end
  end
end
