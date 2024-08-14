defmodule Tomb.Device do
  use TypedStruct

  @moduledoc """
     Devices check in semi-regularly
     Assuming 5 minutes:
      * 12 reports per hour
      * 288 reports per day
      * 105,000 per year

     This is too large for a single aggregate
     We need to close the books on it every day
  """

  alias Tomb.Commands
  alias Tomb.Events
  alias Commanded.Aggregate.Multi

  typedstruct do
    @derive Jason.Encoder
    field :device_id, String.t()
    field :network_id, String.t()
    field :batteryMV, non_neg_integer, default: 0
    field :report_count, non_neg_integer, default: 0
    field :partition_status, :open | :closed
    field :partition, pos_integer, default: 1
    field :next_partition, pos_integer | nil
  end

  def execute(%__MODULE__{partition_status: :closed} = device, _command) do
    {:error, {:partition_closed, device}}
  end

  def execute(device, %Commands.OpenPartition{} = command) do
    if device.partition < command.state.next_partition do
      %Events.DevicePartitionOpened{
        device_id: command.state.device_id,
        partition: command.state.next_partition,
        batteryMV: command.state.batteryMV,
        network_id: command.state.network_id
      }
    end
  end

  def execute(device, %Commands.ClosePartition{}) do
    if device.partition_status == :open do
      %Events.DevicePartitionClosed{
        device_id: device.device_id,
        partition_closed: device.partition,
        next_partition: device.partition + 1
      }
    end
  end

  def execute(device, %Commands.ReportDeviceStatus{} = command) do
    Multi.new(device)
    |> Multi.execute(&maybe_change_battery(&1, command))
    |> Multi.execute(&maybe_close_partition(&1, command))
  end

  def apply(%__MODULE__{} = device, %Events.DeviceBatteryLevelChanged{} = event) do
    %{device | batteryMV: event.to}
    |> increment_report_count()
  end

  def apply(%__MODULE__{} = device, %Events.DevicePartitionOpened{} = event) do
    %{
      device
      | partition_status: :open,
        device_id: event.device_id,
        partition: event.partition,
        batteryMV: event.batteryMV,
        network_id: event.network_id
    }
  end

  def apply(%__MODULE__{} = device, %Events.DevicePartitionClosed{} = event) do
    %{device | partition_status: :closed, next_partition: event.next_partition}
  end

  defp maybe_change_battery(%{batteryMV: old}, %{device_id: id, batteryMV: new}) do
    if new != old do
      %Events.DeviceBatteryLevelChanged{device_id: id, from: old, to: new}
    end
  end

  defp maybe_close_partition(device, %Commands.ReportDeviceStatus{} = event) do
    if device.report_count > 5 do
      %Events.DevicePartitionClosed{
        device_id: event.device_id,
        partition_closed: device.partition,
        next_partition: device.partition + 1
      }
    end
  end

  defp increment_report_count(device) do
    %{device | report_count: device.report_count + 1}
  end
end
