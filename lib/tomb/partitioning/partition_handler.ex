defmodule Tomb.Partitioning.PartitionHandler do
  use Commanded.Event.Handler,
    name: "partition-handler",
    application: Tomb.CommandDispatcher

  alias Tomb.Events.DevicePartitionOpened
  alias Tomb.Partitioning.Partitions

  def handle(%DevicePartitionOpened{} = event, _metadata) do
    Partitions.set(event.device_id, event.partition)
  end
end
