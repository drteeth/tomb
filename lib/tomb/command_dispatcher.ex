defmodule Tomb.CommandDispatcher do
  use Commanded.Application,
    otp_app: :tomb,
    event_store: Application.compile_env!(:tomb, :event_store)

  router(Tomb.Partitioning.CommandRouter)
  router(Tomb.Destructive.CommandRouter)
end
