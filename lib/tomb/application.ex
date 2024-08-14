defmodule Tomb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Tomb.Repo,
      # Start the Telemetry supervisor
      TombWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tomb.PubSub},
      # Start the Endpoint (http/https)
      TombWeb.Endpoint,
      # Start a worker by calling: Tomb.Worker.start_link(arg)
      Tomb.CommandDispatcher,
      Tomb.Partitioning.Partitions
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tomb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TombWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
