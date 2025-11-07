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

        sync_loaded =
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

        for {key, {:async, view, params, _event}} <- unquote(data_sources),
            reduce: sync_loaded do
          {:error, sock} ->
            {:error, sock}

          {:ok, sock} ->
            account = socket.assigns.current_account

            query =
              params
              |> Enum.map(&{&1, load_param(&1, sock)})
              |> Map.new()
              |> Map.put(:__struct__, view)

            Fetcher.subscribe(query)

            {:ok,
             sock
             |> assign_async(
               key,
               fn ->
                 query
                 |> Fetcher.fetch_as(account)
                 |> case do
                   res -> {:ok, %{key => res}}
                 end
               end
             )}
        end
      end
    end
  end

  defmacro register_listener(data_sources) do
    quote do
      for {event, sources} <-
            unquote(data_sources)
            |> Enum.group_by(fn
              {key, {view, params, event}} -> event
              {key, {:async, view, params, event}} -> event
            end) do
        def handle_info({event, _}, sock), do: handle_info(event, sock)

        def handle_info(event, socket) do
          alias RenewCollabCtrl.Fetcher

          sync_loaded =
            for {key, {view, params, ^event}} <- unquote(data_sources), reduce: {:ok, socket} do
              {:error, sock} ->
                {:error, sock}

              {:ok, sock} ->
                params
                |> Enum.map(&{&1, load_param(&1, sock)})
                |> Map.new()
                |> Map.put(:__struct__, view)
                |> Fetcher.fetch_as(socket.assigns.current_account)
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

          for {key, {:async, view, params, ^event}} <- unquote(data_sources),
              reduce: sync_loaded do
            {:error, sock} ->
              {:error, sock}

            {:ok, sock} ->
              account = sock.assigns.current_account

              query =
                params
                |> Enum.map(&{&1, load_param(&1, sock)})
                |> Map.new()
                |> Map.put(:__struct__, view)

              {:ok,
               sock
               |> assign_async(
                 key,
                 fn ->
                   query
                   |> Fetcher.fetch_as(account)
                   |> case do
                     res -> {:ok, %{key => res}}
                   end
                 end
               )}
          end
          |> case do
            {:ok, socket} -> {:noreply, socket}
            o -> o
          end
        end
      end
    end
  end
end
