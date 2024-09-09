defmodule Tomb.Partitioning.CommandRouter do
  use Commanded.Commands.Router

  alias Tomb.Partitioning.Commands
  alias Tomb.Partitioning.Device

  identify(Device, by: :device_uuid, prefix: "device-")
  dispatch(Commands.ReportDeviceStatus, to: Device)
  dispatch(Commands.OpenPartition, to: Device)
  dispatch(Commands.ClosePartition, to: Device)
end
