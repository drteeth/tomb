defmodule Tomb.CommandRouter do
  use Commanded.Commands.Router

  alias Tomb.Commands
  alias Tomb.Device

  identify(Device, by: :device_uuid, prefix: "device-")
  dispatch(Commands.ReportDeviceStatus, to: Device)
  dispatch(Commands.OpenPartition, to: Device)
  dispatch(Commands.ClosePartition, to: Device)
end
