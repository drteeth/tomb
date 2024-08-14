defmodule Tomb.Events do
  use TypedStruct

  typedstruct module: DeviceBatteryLevelChanged, enforce: true do
    @derive Jason.Encoder
    field :device_id, String.t()
    field :from, non_neg_integer
    field :to, non_neg_integer
    field :version, non_neg_integer, default: 1
  end

  typedstruct module: DevicePartitionOpened, enforce: true do
    @derive Jason.Encoder
    field :device_id, String.t()
    field :network_id, String.t()
    field :batteryMV, non_neg_integer
    field :partition, pos_integer
    field :version, non_neg_integer, default: 1
  end

  typedstruct module: DevicePartitionClosed, enforce: true do
    @derive Jason.Encoder
    field :device_id, String.t()
    field :partition_closed, pos_integer
    field :next_partition, pos_integer
    field :version, non_neg_integer, default: 1
  end
end
