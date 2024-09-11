defmodule Tomb.Destructive do
  alias Tomb.CommandDispatcher
  alias Tomb.Destructive.Commands

  def report_device_status(device_id, batteryMV) do
    command = %Commands.ReportDeviceStatus{
      device_id: device_id,
      batteryMV: batteryMV
    }

    CommandDispatcher.dispatch(command)
  end

  def close_reporting_period(device_id) do
    CommandDispatcher.dispatch(%Commands.CloseReportingPeriod{device_id: device_id})
  end
end
