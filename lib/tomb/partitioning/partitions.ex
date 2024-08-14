defmodule Tomb.Partitioning.Partitions do
  use GenServer

  @name __MODULE__

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def init(state), do: {:ok, state}

  def set(device_id, partition) do
    GenServer.call(@name, {:set, device_id, partition})
  end

  def get(device_id) do
    GenServer.call(@name, {:get, device_id})
  end

  def handle_call({:set, device_id, partition}, _from, state) do
    state = Map.put(state, device_id, partition)
    {:reply, :ok, state}
  end

  def handle_call({:get, device_id}, _from, state) do
    partition = Map.get(state, device_id, 1)
    {:reply, partition, state}
  end
end
