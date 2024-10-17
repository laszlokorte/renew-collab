defmodule RenewCollabWeb.StateChannel do
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def redux do
    quote do

      def join(channel, payload, socket) do
        import Phoenix.Socket
        case authorize(channel, payload, socket) do
          {:ok, socket} ->
            send(self(), {:after_join, channel, payload})
            connection_id = Ecto.UUID.generate()
            {:ok, %{connection_id: connection_id}, socket|>assign(:connection_id, connection_id)}

          {:error, reason} ->
            {:error, reason}
        end
      end

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
          :silent ->
            {:noreply, socket}

          :ack ->
            {:noreply, socket} =
              maybe_handle_reply({:noreply, Map.get(assigns, state_key())}, socket)

            {:reply, :ok, socket}

          r ->
            maybe_handle_reply(r, socket)
        end
      end
    end
  end
end
