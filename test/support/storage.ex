defmodule Tomb.Storage do
  @doc """
  Reset the event store.
  """
  def reset! do
    reset_eventstore!()
  end

  defp reset_eventstore! do
    config = Tomb.EventStore.config()
    {:ok, conn} = Postgrex.start_link(config)
    {:ok, :ok} = EventStore.Storage.Initializer.reset!(conn, config)
    :ok
  end
end
