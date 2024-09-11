import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

partition =
  case System.get_env("MIX_TEST_PARTITION") do
    nil -> nil
    n -> String.to_integer(n)
  end

config :tomb, Tomb.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tomb_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :tomb, Tomb.EventStore,
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  database: "tomb_eventstore_test#{partition}",
  serializer: Commanded.Serialization.JsonSerializer,
  pool_size: 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tomb, TombWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "cMo71QUahcIZOUecranG54vf7C67iWTySii//JoAvEBiU2v0SexLkU383no/SPhu",
  server: false

# In test we don't send emails.
config :tomb, Tomb.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
