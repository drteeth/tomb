defmodule Tomb.Repo do
  use Ecto.Repo,
    otp_app: :tomb,
    adapter: Ecto.Adapters.Postgres
end
