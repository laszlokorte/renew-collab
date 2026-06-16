defmodule RenewCollabWeb.UndoRedoComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div style="display: flex; align-items: grow">
      <%= if @undo_redo do %>
        <div style="display: flex; gap: 0.5ex; flex-grow: 1;">
          <%= if is_nil(@undo_redo.predecessor_id) do %>
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
            <% [suc_id] -> %>
              <button
                style="cursor: pointer; width: 6em; padding: 1ex; border: none; background: #eff; color: #000"
                phx-click="restore"
                phx-value-id={suc_id}
              >
                Redo
              </button>
            <% more -> %>
              <div style="max-height: 2em; overflow: visible; position: relative; z-index: 3; display: flex; flex-direction: column; gap: 0.5ex; align-self: stretch;">
                <%= for {suc_id, i} <- more|>Enum.with_index do %>
                  <button
                    style="flex-grow: 1;width: 6em; justify-content: stretch; cursor: pointer;padding: 0.3ex 1ex; border: none; background: #eff; color: #000"
                    phx-click="restore"
                    phx-value-id={suc_id}
                  >
                    Redo ({i})
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
