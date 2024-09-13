defmodule Tomb.DestructiveTest do
  use Tomb.DataCase

  alias Tomb.Destructive
  alias Tomb.Destructive.Device
  alias Tomb.Destructive.Events.ReportingPeriodClosed
  alias Tomb.Destructive.CommandRouter

  test "closing the books after 5 reports" do
    device_id = Tomb.generate_id()
    stream_uuid = CommandRouter.stream_uuid(Device, device_id)

    # Given we emit some events
    :ok = Destructive.report_device_status(device_id, 111)
    :ok = Destructive.report_device_status(device_id, 222)
    :ok = Destructive.report_device_status(device_id, 333)

    # When we close the reporting period
    :ok = Destructive.close_reporting_period(device_id)

    assert_receive_event(ReportingPeriodClosed, fn e ->
      assert e.batteryMV == 333
    end)

    # Then the stream should only contain the tombstone event
    {:ok, events} = Tomb.EventStore.read_stream_forward(stream_uuid)
    assert Enum.count(events) == 1
  end
end
