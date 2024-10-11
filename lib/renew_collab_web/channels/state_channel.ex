defmodule RenewCollabWeb.StateChannel do
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def redux do
    quote do
      use LiveState.Channel, web_module: RenewCollabWeb

      @impl true
      def handle_in("lvs_evt:" <> event_name, payload, %{assigns: assigns} = socket) do
        if function_exported?(__MODULE__, :handle_event, 4) do
          apply(__MODULE__, :handle_event, [
            event_name,
            payload,
            Map.get(assigns, state_key()),
            socket
          ])
        else
          apply(__MODULE__, :handle_event, [event_name, payload, Map.get(assigns, state_key())])
        end
        |> case do
          :ack ->
            {:noreply, socket} =
              maybe_handle_reply({:noreply, Map.get(assigns, state_key())}, socket)

            dbg("xxxxxx")
            {:reply, :ok, socket}

          r ->
            maybe_handle_reply(r, socket)
        end
      end
    end
  end
end
