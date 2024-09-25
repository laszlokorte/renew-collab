defmodule RenewCollabWeb.SnapshotListComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
        <button type="button" phx-click="create_snapshot"  style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff">Create Snaphot</button>
        <button type="button" phx-click="prune_snaphots"  style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff">Prune Snaphots</button>
        <div style="width: 45vw">
          <%= for {day, snaps} <- @snapshots |> Enum.group_by(&DateTime.to_date(&1.inserted_at))|>Enum.reverse do %>
      <h5 style="margin: 0;"><%= day|> Calendar.strftime("%Y-%m-%d")  %></h5>
      <ul style="margin: 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 0.2ex">
        <%= for s <- snaps  do %>
          <li style="display: flex; align-items: center;gap: 1ex;">
          <%= if s.is_latest do %>
          <span style="cursor: default; font-size: 10pt; font-family: sans-serif; width: max-content; display: inline; padding: 1ex; border: none; background: #33a; color: #fff">
            Current</span>
          <%= s.inserted_at |> Calendar.strftime("%H:%M:%S")  %>

          <%= if not is_nil(s.label) do %>
                    <button phx-click="remove_snapshot_label" phx-value-id={s.id} type="button"  style="text-align: center; align-self: center; cursor: pointer; border: none; background: #eaa; color: #fff; width: 1.8em; height: 1.8em; display: grid; place-content: center; place-items: center; border-radius: 10%; font-weight: bold;" title="Remove Pin">📌</button>

          <%= s.label %>
          <% else %>
          <form phx-hook="RnwSnapshotPin" rnw-snapshot-id={s.id} id={"pin-snapshot-#{s.id}"} style="display: flex; align-items: stretch; gap: 0.2ex">
            <button  style="text-align: center; align-self: center; cursor: pointer; border: none; background: #aea; color: #fff; width: 1.8em; height: 1.8em; display: grid; place-content: center; place-items: center; border-radius: 10%; font-weight: bold;" type="submit">📌</button>
            <input name="description" type="text" placeholder="Description"> 
          </form>
          <% end %>

          <% else %>
            <button  style="font-size: 10pt; font-family: sans-serif; cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff" phx-click="restore" phx-value-id={s.id}>
            Restore</button><%= s.inserted_at |> Calendar.strftime("%H:%M:%S")  %>

            <%= if not is_nil(s.label)  do %>
          <button phx-click="remove_snapshot_label" phx-value-id={s.id} type="button"  style="text-align: center; align-self: center; cursor: pointer; border: none; background: #eaa; color: #fff; width: 1.8em; height: 1.8em; display: grid; place-content: center; place-items: center; border-radius: 10%; font-weight: bold;" title="Remove Pin">📌</button>
            <%= s.label %>
          
          <% end%>
          <% end %>
          </li>
        <% end %>
      </ul>
        <% end %>
        </div>
      </div>
    """
  end
end
