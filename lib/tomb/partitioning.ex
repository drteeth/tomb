defmodule Tomb.Partitioning do
  alias Tomb.CommandDispatcher
  alias Tomb.Partitioning.Commands
  alias Tomb.Partitioning.Partitions

  def report_device_status(device_id, batteryMV, opts \\ []) do
    command = %Commands.ReportDeviceStatus{
      device_uuid: device_uuid(device_id),
      device_id: device_id,
      batteryMV: batteryMV
    }

    dispatch(command, opts)
  end

  def close_partition(device_id) do
    command = %Commands.ClosePartition{
      device_uuid: device_uuid(device_id),
      device_id: device_id
    }

    dispatch(command, include_execution_result: true)
  end

  defp dispatch(command, opts) do
    with {:error, {:partition_closed, state}} <- CommandDispatcher.dispatch(command, opts) do
      # the dispatch failed because this stream is closed
      # Try to open the next stream, if it is already open it will no-op
      open_command = Commands.OpenPartition.from(state)

      case dispatch(open_command, include_execution_result: true) do
        {:ok, %{aggregate_state: state}} ->
          # The stream is open, patch the ID we're address the command to
          command = %{command | device_uuid: device_uuid(state.device_id, state.partition)}
          dispatch(command, opts)
      end
    end
  end

  def device_uuid(device_id) do
    partition = Partitions.get(device_id)
    device_uuid(device_id, partition)
  end

  def device_uuid(device_id, partition) do
    "#{device_id}:#{partition}"
  end
end
