defmodule Tomb.Destructive.HandlerOfDestruction do
  use Commanded.Event.Handler,
    name: __MODULE__,
    application: Tomb.CommandDispatcher

  alias Tomb.CommandDispatcher
  alias Tomb.Destructive.Events

  def handle(%Events.ReportingPeriodClosed{} = event, metadata) do
    # TODO: find a good way of getting the prefixed stream name from Commanded.
    events = Commanded.EventStore.stream_forward(CommandDispatcher, "device-" <> event.device_id)

    stream_id = metadata.stream_id
    version = metadata.stream_version

    with :ok <- backup_events_to_cold_storage(events),
         :ok <- Tomb.EventStore.trim_stream(stream_id, version) do
      publish(event.device_id, version)
    end
  end

  def wait_for_stream_to_be_trimmed(device_id, work_fn) do
    topic = topic(device_id)

    try do
      :ok = Phoenix.PubSub.subscribe(Tomb.PubSub, topic)
      work_fn.()

      receive do
        {:stream_trimmed, ^device_id, version} ->
          {:ok, version}
      end
    after
      :ok = Phoenix.PubSub.unsubscribe(Tomb.PubSub, topic)
    end
  end

  defp publish(device_id, version) do
    Phoenix.PubSub.broadcast(
      Tomb.PubSub,
      topic(device_id),
      {:stream_trimmed, device_id, version}
    )
  end

  defp topic(device_id) do
    "stream-trimmer-#{device_id}"
  end

  defp backup_events_to_cold_storage(_events) do
    # Pretend we back these up to cold storage somewhere like S3
    :ok
  end
end
