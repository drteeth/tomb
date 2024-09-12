defmodule Tomb.DestructiveTest do
  use Tomb.DataCase

  alias Tomb.Destructive
  alias Tomb.Destructive.Events.ReportingPeriodClosed

  test "closing the books after 5 reports" do
    device_id = Tomb.generate_id()

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
    # TODO: figure out how to get the prefixed stream_id from Commanded
    stream_id = "device-#{device_id}"
    {:ok, events} = Tomb.EventStore.read_stream_forward(stream_id)
    assert Enum.count(events) == 1
  end
end
