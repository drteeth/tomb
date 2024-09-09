defmodule Tomb.Partitioning.Commands do
  use TypedStruct

  typedstruct module: ReportDeviceStatus, enforce: true do
    field :device_uuid, String.t()
    field :device_id, String.t()
    field :batteryMV, non_neg_integer()
  end

  typedstruct module: ClosePartition, enforce: true do
    field :device_uuid, String.t()
    field :device_id, String.t()
  end

  typedstruct module: OpenPartition, enforce: true do
    field :device_uuid, String.t()
    field :state, map()

    def from(state) do
      id = state.device_id
      partition = state.next_partition
      uuid = "#{id}:#{partition}"
      __MODULE__.__struct__(device_uuid: uuid, state: state)
    end
  end
end
