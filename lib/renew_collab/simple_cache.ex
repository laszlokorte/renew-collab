defmodule RenewCollab.SimpleCache do
  use GenServer

  @initial_state %{entries: Map.new(), tags: Map.new()}

  @doc false
  @opaque t :: %__MODULE__{value: term(), updated_at: Time.t()}
  defstruct [:value, :updated_at]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def cache(key, fun, tags, lifetime \\ :infinity)
      when is_function(fun) and
             (lifetime == :infinity or (is_integer(lifetime) and lifetime >= 0)) do
    case GenServer.call(__MODULE__, {:get, key, lifetime}) do
      {:ok, value} ->
        value

      :error ->
        value = fun.()
        GenServer.cast(__MODULE__, {:put, key, value, tags})
        value
    end
  end

  def delete_tag(tag), do: GenServer.cast(__MODULE__, {:delete_tag, tag})
  def delete_tags(tags), do: GenServer.cast(__MODULE__, {:delete_tags, tags})

  def clear(), do: GenServer.cast(__MODULE__, :clear)

  def size() do
    with {:ok, entries} <- GenServer.call(__MODULE__, :size) do
      entries
    end
  end

  @impl true
  def init(_opts), do: {:ok, @initial_state}

  @impl true
  def handle_cast({:put, key, value, new_tags}, %{entries: entries, tags: existing_tags} = state) do
    cached = struct(__MODULE__, value: value, updated_at: Time.utc_now())

    {:noreply,
     %{
       state
       | entries: Map.put(entries, key, cached),
         tags:
           new_tags
           |> Enum.reduce(existing_tags, fn new_tag, tag_map ->
             Map.update(tag_map, new_tag, MapSet.new([key]), &MapSet.put(&1, key))
           end)
     }}
  end

  @impl true
  def handle_cast({:delete_tag, tag}, %{entries: entries, tags: tags}) do
    {:noreply,
     %{
       entries: Map.drop(entries, Map.get(tags, tag, MapSet.new()) |> Enum.into([])),
       tags: Map.delete(tags, tag)
     }}
  end

  @impl true
  def handle_cast({:delete_tags, tags_to_delete}, state) do
    {:noreply,
     tags_to_delete
     |> Enum.reduce(state, fn tag, %{entries: entries, tags: existing_tags} ->
       %{
         entries: Map.drop(entries, Map.get(existing_tags, tag, MapSet.new()) |> Enum.into([])),
         tags: Map.delete(existing_tags, tag)
       }
     end)}
  end

  @impl true
  def handle_cast(:clear, _state) do
    {:noreply, @initial_state}
  end

  @impl true
  def handle_call({:get, key, :infinity}, _from, %{entries: entries} = state) do
    case Map.fetch(entries, key) do
      {:ok, cached} -> {:reply, {:ok, cached.value}, state}
      :error -> {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:get, key, lifetime}, _from, %{entries: entries} = state) do
    with {:ok, cached} <- Map.fetch(entries, key),
         now <- Time.utc_now(),
         true <- Time.diff(now, cached.updated_at) < lifetime do
      cached = struct(cached, updated_at: now)
      {:reply, {:ok, cached.value}, %{state | entries: Map.put(entries, key, cached)}}
    else
      _cached_expired_or_key_not_found ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call(:clear, _from, _state) do
    {:reply, :ok, @initial_state}
  end

  @impl true
  def handle_call(:size, _from, %{entries: entries} = state) do
    {:reply, {:ok, Kernel.map_size(entries)}, state}
  end
end
