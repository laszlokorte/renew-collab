defmodule RenewCollabCtrl.Helper do
  defmodule Callback do
    @callback load_param(param :: atom, socket :: Phoenix.LiveView.Socket) :: any
  end

  defmacro __using__(opts) do
    quote do
      @behaviour RenewCollabCtrl.Helper.Callback
      RenewCollabCtrl.Helper.register_listener(unquote(opts))

      RenewCollabCtrl.Helper.define_loader(unquote(opts))
    end
  end

  defmacro define_loader(data_sources) do
    quote do
      def load_data(socket, initial) do
        alias RenewCollabCtrl.Fetcher

        for {key, {view, params, _event}} <- unquote(data_sources), reduce: {:ok, socket} do
          {:error, sock} ->
            {:error, sock}

          {:ok, sock} ->
            query =
              params
              |> Enum.map(&{&1, load_param(&1, sock)})
              |> Map.new()
              |> Map.put(:__struct__, view)

            if initial do
              query |> Fetcher.fetch_and_subscribe(socket.assigns.current_account)
            else
              query |> Fetcher.fetch_as(socket.assigns.current_account)
            end
            |> case do
              nil ->
                {:error,
                 sock
                 |> assign(
                   key,
                   nil
                 )}

              data ->
                {:ok,
                 sock
                 |> assign(
                   key,
                   data
                 )}
            end
        end
      end
    end
  end

  defmacro register_listener(data_sources) do
    quote bind_quoted: [data_sources: data_sources] do
      for {key, {view, params, event}} <- data_sources do
        def handle_info({unquote(event), _}, sock), do: handle_info(unquote(event), sock)

        def handle_info(unquote(event), sock) do
          alias RenewCollabCtrl.Fetcher

          data =
            unquote(params)
            |> Enum.map(&{&1, load_param(&1, sock)})
            |> Map.new()
            |> Map.put(:__struct__, unquote(view))
            |> Fetcher.fetch_as(sock.assigns.current_account)

          sock
          |> assign(
            unquote(key),
            data
          )
          |> then(&{:noreply, &1})
        end
      end
    end
  end
end
