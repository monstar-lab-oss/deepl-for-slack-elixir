use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :deep_thought, DeepThought.Repo,
  username: "postgres",
  password: "postgres",
  database: "deep_thought_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :deep_thought, DeepThoughtWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :tesla, adapter: Tesla.Mock

config :deep_thought, :deepl, auth_key: "auth_key"

config :deep_thought, :slack,
  bot_token: "bot_token",
  signing_secret: "signing_secret"
