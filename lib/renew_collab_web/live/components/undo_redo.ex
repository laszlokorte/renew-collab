defmodule RenewCollabWeb.UndoRedoComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div style="display: flex; align-items: grow">
      <%= if @undo_redo do %>
        <div style="display: flex; gap: 0.5ex; flex-grow: 1;">
          <%= if @undo_redo.predecessor_id == @undo_redo.id do %>
            <button
              style="cursor: pointer; width: 6em; padding: 1ex; border: none; background: #eff; color: #000; opacity: 0.3;"
              disabled
            >
              Undo
            </button>
          <% else %>
            <button
              style="cursor: pointer; width: 6em; padding: 1ex; border: none; background: #eff; color: #000"
              phx-click="restore"
              phx-value-id={@undo_redo.predecessor_id}
            >
              Undo
            </button>
          <% end %>

          <%= case @undo_redo.successors do %>
            <% [] -> %>
              <button
                style="padding: 1ex; width: 6em; border: none; background: #eff; color: #000; opacity: 0.3;"
                disabled
              >
                Redo
              </button>
            <% [a] -> %>
              <%= if a.id == @undo_redo.id do %>
                <button
                  style="cursor: pointer; width: 6em; padding: 1ex; border: none; background: #eff; color: #000; opacity: 0.3;"
                  disabled
                >
                  Redo
                </button>
              <% else %>
                <button
                  style="cursor: pointer; width: 6em; padding: 1ex; border: none; background: #eff; color: #000"
                  phx-click="restore"
                  phx-value-id={a.id}
                >
                  Redo
                </button>
              <% end %>
            <% more -> %>
              <div style="display: flex; flex-direction: column; gap: 0.5ex; align-self: stretch;">
                <%= for {a, i} <- more|>Enum.with_index do %>
                  <button
                    style="flex-grow: 1;width: 6em; justify-content: stretch; cursor: pointer;padding: 0.3ex 1ex; border: none; background: #eff; color: #000"
                    phx-click="restore"
                    phx-value-id={a.id}
                  >
                    Redo (<%= i %>)
                  </button>
                <% end %>
              </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
