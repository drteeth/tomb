defmodule Tomb.Destructive.Device do
  use TypedStruct

  alias Tomb.Destructive.Commands
  alias Tomb.Destructive.Events

  typedstruct do
    @derive Jason.Encoder
    field :device_id, String.t()
    field :batteryMV, non_neg_integer, default: 0
  end

  def execute(%{batteryMV: old}, %Commands.ReportDeviceStatus{device_id: id, batteryMV: new}) do
    if new != old do
      %Events.DeviceBatteryLevelChanged{device_id: id, from: old, to: new}
    end
  end

  def execute(device, %Commands.CloseReportingPeriod{}) do
    %Events.ReportingPeriodClosed{
      device_id: device.device_id,
      batteryMV: device.batteryMV
    }
  end

  def apply(%__MODULE__{} = device, %Events.DeviceBatteryLevelChanged{} = event) do
    %{device | device_id: event.device_id, batteryMV: event.to}
  end

  def apply(%__MODULE__{} = device, %Events.ReportingPeriodClosed{} = _event) do
    device
  end
end
