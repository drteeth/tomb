defmodule TombTest do
  use Tomb.DataCase, async: true

  alias Tomb.Events

  setup do
    start_supervised!(Tomb.Partitioning.PartitionHandler)
    :ok
  end

  test "we can report on a device" do
    device_id = Tomb.generate_id()

    :ok = Tomb.report_device_status(device_id, 3400)

    assert_receive_event(
      Events.DeviceBatteryLevelChanged,
      &(&1.device_id == device_id),
      fn e ->
        assert e.device_id == device_id
        assert e.from == 0
        assert e.to == 3400
      end
    )
  end

  test "closing the books after 5 reports" do
    device_id = Tomb.generate_id()

    Enum.each(1..25, fn n ->
      :ok = Tomb.report_device_status(device_id, n)
    end)

    {:ok, %{aggregate_state: state}} =
      Tomb.report_device_status(device_id, 5, include_execution_result: true)

    assert state.partition == 5
  end
end
