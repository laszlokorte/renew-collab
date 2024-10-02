defmodule RenewCollab.SimpleCache do
  use GenServer

  @doc false
  @opaque t :: %__MODULE__{value: term(), updated_at: Time.t()}
  defstruct [:value, :updated_at]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def cache(key, fun, lifetime \\ :infinity)
      when is_function(fun) and
             (lifetime == :infinity or (is_integer(lifetime) and lifetime >= 0)) do
    case GenServer.call(__MODULE__, {:get, key, lifetime}) do
      {:ok, value} ->
        value

      :error ->
        value = fun.()
        GenServer.cast(__MODULE__, {:put, key, value})
        value
    end
  end

  def delete(key), do: GenServer.cast(__MODULE__, {:delete, key})

  def clear(), do: GenServer.cast(__MODULE__, :clear)

  def size() do
    with {:ok, entries} <- GenServer.call(__MODULE__, :size) do
      entries
    end
  end

  @impl true
  def init(_opts), do: {:ok, %{}}

  @impl true
  def handle_cast({:put, key, value}, state) do
    cached = struct(__MODULE__, value: value, updated_at: Time.utc_now())
    {:noreply, Map.put(state, key, cached)}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  @impl true
  def handle_cast(:clear, _state) do
    {:noreply, Map.new()}
  end

  @impl true
  def handle_call({:get, key, :infinity}, _from, state) do
    case Map.fetch(state, key) do
      {:ok, cached} -> {:reply, {:ok, cached.value}, state}
      :error -> {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:get, key, lifetime}, _from, state) do
    with {:ok, cached} <- Map.fetch(state, key),
         now <- Time.utc_now(),
         true <- Time.diff(now, cached.updated_at) < lifetime do
      cached = struct(cached, updated_at: now)
      {:reply, {:ok, cached.value}, Map.put(state, key, cached)}
    else
      _cached_expired_or_key_not_found ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    {:reply, :ok, Map.delete(state, key)}
  end

  @impl true
  def handle_call(:clear, _from, _state) do
    {:reply, :ok, Map.new()}
  end

  @impl true
  def handle_call(:size, _from, state) do
    {:reply, {:ok, Map.size(state)}, state}
  end
end
