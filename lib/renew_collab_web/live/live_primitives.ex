defmodule RenewCollabWeb.LivePrimitives do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  @topic "primitives"

  def mount(_params, _session, socket) do
    # TODO:subscription
    RenewCollabWeb.Endpoint.subscribe(@topic)

    {:ok, load_data(socket)}
  end

  def handle_info({_, _}, socket) do
    {:noreply, load_data(socket)}
  end

  defp load_data(socket) do
    current_account = socket.assigns.current_account

    socket
    |> assign(
      :primitive_groups,
      %Views.GlobalPrimitives{}
      |> Fetcher.fetch_as(current_account)
    )
    |> assign(:create_form, to_form(%{"name" => nil}, as: :create_group))
    |> assign_async(
      [
        :symbols,
        :sockets
      ],
      fn ->
        {:ok,
         %{
           sockets:
             %Views.GlobalSocketById{}
             |> Fetcher.fetch_as(current_account),
           symbols:
             %Views.GlobalSymbolsList{}
             |> Fetcher.fetch_as(current_account)
             |> Enum.map(fn s -> {s.id, s} end)
             |> Map.new()
         }}
      end
    )
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} />
      <div style="padding: 1em">
        /
        Predefined Primitives
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: center;">
          <img class="icon" src="/assets/icon-lego.svg" />
          <span>
            Primitives
          </span>
        </h2>
      </div>
      <div style="padding: 1em">
        <.form for={@create_form} phx-change="validate" phx-submit="save">
          <div style="display: flex; gap: 1ex; align-items: stretch">
            <.input style="padding: 1ex" type="text" field={@create_form[:name]} />
            <button style="background: #333; color: #fff; padding: 1ex; border: none">
              Create Group
            </button>
          </div>
        </.form>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" colspan="1"></th>

              <th style="border-bottom: 1px solid #333;" align="left" width="500" colspan="1">
                Name
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="500" colspan="1">
                Icon
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="500" colspan="1">
                Data
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="4">
                Actions
              </th>
            </tr>
          </thead>

          <%= if Enum.empty?(@primitive_groups) do %>
            <tbody>
              <tr>
                <td colspan="7">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Primitives defined yet.
                  </div>
                </td>
              </tr>
            </tbody>
          <% else %>
            <%= for group <- @primitive_groups do %>
              <thead>
                <tr {[style: "background-color:#333;color: #fff"]}>
                  <th align="left">Icon</th>

                  <th align="left" colspan="2">
                    <strong>{group.name}</strong>
                  </th>

                  <th></th>

                  <th align="left" width="50">
                    <button
                      type="button"
                      value={group.id}
                      phx-click="delete_group"
                      style="cursor: pointer; background: #a00; color: #fff; padding: 1ex; border: none"
                    >
                      Delete
                    </button>
                  </th>
                </tr>
              </thead>

              <tbody>
                <%= if Enum.empty?(group.primitives) do %>
                  <tr>
                    <td colspan="7">
                      <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                        No Primitives defined yet.
                      </div>
                    </td>
                  </tr>
                <% else %>
                  <%= for {primitive, si} <- group.primitives |> Enum.with_index do %>
                    <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                      <td>
                        <svg viewBox="-8 -8 48 48" style="width: 3em">
                          {raw(primitive.icon)}
                        </svg>
                      </td>

                      <td align="left" colspan="1">
                        {primitive.name}
                      </td>

                      <td align="left" colspan="1">
                        <textarea readonly rows="5" cols="40">{primitive.icon}</textarea>
                      </td>

                      <td align="left" colspan="1">
                        <textarea readonly rows="5" cols="40">{Jason.encode!(primitive.data)}</textarea>
                      </td>

                      <td align="left" width="50">
                        <button
                          type="button"
                          value={primitive.id}
                          phx-click="delete_primitive"
                          style="cursor: pointer; background: #a00; color: #fff; padding: 1ex; border: none"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  <% end %>
                <% end %>
              </tbody>
              <tr>
                <td valign="top">Add Primitive</td>
                <td valign="top">
                  <input
                    style="padding: 1ex"
                    form={"add_primitive-#{group.id}"}
                    type="text"
                    name="name"
                  />
                </td>
                <td valign="top">
                  <textarea form={"add_primitive-#{group.id}"} name="icon" rows="5" cols="40"></textarea>
                </td>
                <td valign="top">
                  <textarea form={"add_primitive-#{group.id}"} name="data" rows="5" cols="40"></textarea>
                </td>
                <td valign="top">
                  <form id={"add_primitive-#{group.id}"} phx-submit="add_primitive">
                    <input type="hidden" name="group_id" value={group.id} />
                    <button
                      type="submit"
                      style="cursor: pointer; background: #0a0; color: #fff; padding: 1ex; border: none"
                    >
                      add
                    </button>
                  </form>
                </td>
              </tr>
            <% end %>
          <% end %>
        </table>
      </div>
    </div>
    """
  end

  def handle_event("validate", %{"create_group" => %{"name" => name}}, socket) do
    {:noreply, socket |> assign(:create_form, to_form(%{"name" => name}, as: :create_group))}
  end

  def handle_event("save", %{"create_group" => attributes}, socket) do
    %Actions.GlobalPrimitivesCreateGroup{attributes: attributes}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    # Primitives.create(params)
    |> case do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Group created")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not create group")}
    end
  end

  def handle_event("delete_group", %{"value" => group_id}, socket) do
    %Actions.GlobalPrimitivesDeleteGroup{group_id: group_id}
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket |> put_flash(:info, "Group deleted")}
  end

  def handle_event("delete_primitive", %{"value" => definition_id}, socket) do
    %Actions.GlobalPrimitivesDeleteDefinition{definition_id: definition_id}
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket |> put_flash(:info, "Definition deleted")}
  end

  def handle_event("add_primitive", attributes, socket) do
    %Actions.GlobalPrimitivesCreateDefinition{attributes: attributes}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Definition created")
         |> assign(:create_form, to_form(%{"name" => ""}, as: :create_group))}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not create definition")}
    end
  end
end
