defmodule Tomb.DestructiveTest do
  use Tomb.DataCase

  alias Tomb.Destructive
  alias Tomb.Destructive.HandlerOfDestruction
  alias Tomb.Destructive.Events.ReportingPeriodClosed

  setup do
    start_supervised!(HandlerOfDestruction)
    :ok
  end

  test "closing the books after 5 reports" do
    device_id = Tomb.generate_id()

    # Given we emit some events and then close the reporting period
    HandlerOfDestruction.wait_for_stream_to_be_trimmed(device_id, fn ->
      :ok = Destructive.report_device_status(device_id, 111)
      :ok = Destructive.report_device_status(device_id, 222)
      :ok = Destructive.report_device_status(device_id, 333)
      :ok = Destructive.close_reporting_period(device_id)
    end)

    # Then the stream should only contain the tombstone event
    # TODO: figure out how to get the prefixed stream_id from Commanded
    stream_id = "device-#{device_id}"
    {:ok, events} = Tomb.EventStore.read_stream_forward(stream_id)
    assert Enum.count(events) == 1

    event = List.first(events)
    assert event.stream_version == 4
    assert event.event_number == 4
    assert event.event_type == to_string(ReportingPeriodClosed)
  end
end
