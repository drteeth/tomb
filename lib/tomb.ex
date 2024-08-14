defmodule Tomb do
  @moduledoc """
  Tomb keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Tomb.Commands
  alias Tomb.CommandDispatcher
  alias Tomb.Partitioning.Partitions

  def generate_id() do
    Ecto.UUID.generate()
  end

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
      open_command = Commands.OpenPartition.from(state)

      case dispatch(open_command, include_execution_result: true) do
        {:ok, %{aggregate_state: state}} ->
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
