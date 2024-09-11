defmodule Tomb.EventStore do
  use EventStore, otp_app: :tomb, enable_hard_deletes: true
end
