defmodule Tomb.Destructive.CommandRouter do
  use Commanded.Commands.Router

  alias Tomb.Destructive.Commands
  alias Tomb.Destructive.Device

  identify(Device, by: :device_id, prefix: "device-")
  dispatch(Commands.ReportDeviceStatus, to: Device)
  dispatch(Commands.CloseReportingPeriod, to: Device)
end
