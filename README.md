# Tomb

Exploring "Closing the books" or "Tombstoning" in [https://github.com/commanded/commanded](Commanded).

### Motivating example

I've created a Commanded app that models some `Device` which receives battery reports from some unseen source. Imagine a battery powered IoT device that checks in regularly to let our service know about it's battery health. If this device reports it's battery level every 5 minutes, in a year we'll have more than 100,000 events in it's stream. Snapshotting would work here, but the point here is to explore what a tombstone implementation might look like.

Unlike some domains, there is no natural domain process that mirrors closing the books in this case, so we have to make an arbitrary choice. We could partition the stream by time (e.g.: every day), by number of events (e.g.: after every 100 events), or some other mechanism. We have the choice to have the partition pushed on the aggregate from the outside (some scheduled command) or it could be that the aggregate decides to close it's own stream during the handling of some other command.

I've chosen to let the Device close it's own partition after every 5 reports.

One of the problems with partitining a stream like this is that callers shouldn't need to know about the partitioning scheme. In this example, when a partition is closed, and a command is dispatched against it, an error is returned:

```elixir
{:error, {:partition_closed, info_about_the_next_partition}}
```

The struct that is returned includes data about the next partition which the caller should try to find the current, open, partition. It's possible that the next partition has also been closed, and so we walk the partitions recursively until we get the open one, and dispatch our command against that.

In order to optimize that slightly, an eventually consistent read model is kept which allows callers to lookup the latest partition and skip this recursive walk. If the read model is behind, the callers can use the recursive strategy to walk the last hop to find the open partition. In a real app this read model would likely be a SQL projection, but in this example it's a GenServer that holds this state in memory (See `Tomb.Partitioning.Partitions`).

As each partition has it's own stream, it would be possible to create an `Event.Handler` to copy the events for closed partitions into long term storage (e.g.: S3) and use `Tomb.EventStore.delete_stream(stream_uuid, :any_version, :hard)` to remove the data from the event stream AFTER storing a reference to a later partition.

### Running the example test

Running the test will send 25 reports to the device which should create 5 partitions.

```elixir
mix test test/tomb_test.exs
```

### Alternatives to explore

#### Closing the books every day using stream prefixing
It possible to use a zero-arity function (a 'thunk'!) to prefix the stream for your aggregate, which we could use to change the active partition:

```elixir
def partition_by_date() do
  "device-#{Date.utc_today()}"
end

identify(Device, by: :device_uuid, prefix: &partition_by_date/0`
```

This could work well in that callers don't need to know anything about partitions, but now we need to coordinate between the clocks, and the mechanics of closing and opening streams. Further clock-drift becomes a factor in multi-node deployments.

#### Destructively trimming a single stream
Instead of using multiple streams and some hand-over mechanism, it should be possible to close the stream with a single event (containing the state to carry forward), and then remove earlier events from the database. This would involve disabling Commanded EventStore's protections against mutating the eventstream, and I suspect it would involve writing SQL against EventStore's implementation. The trimming could be triggered by an event handler and could backup these older events to cold storage before performing the delete.

#### Closing the stream from the outside
How does having a scheduled command start off a cross-aggregate process of closing one partition and opening another work? What challenges are there in handling commands that arrive in the middle of the handover?
