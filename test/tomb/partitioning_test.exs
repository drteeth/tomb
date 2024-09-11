defmodule TombPartitioningTest do
  use Tomb.DataCase

  alias Tomb.Partitioning

  setup do
    start_supervised!(Tomb.Partitioning.PartitionHandler)
    :ok
  end

  test "closing the books after 5 reports" do
    device_id = Tomb.generate_id()

    Enum.each(1..25, fn n ->
      :ok = Partitioning.report_device_status(device_id, n)
    end)

    {:ok, %{aggregate_state: state}} =
      Partitioning.report_device_status(device_id, 5, include_execution_result: true)

    assert state.partition == 5
  end
end
