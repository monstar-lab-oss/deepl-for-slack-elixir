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

# Secret variables with dummy values
deepl_auth_key = "auth_key"

config :deep_thought, :deepl, auth_key: deepl_auth_key

slack_bot_token = "bot_token"

# this value is used in test cases
slack_signing_secret = "secret"

slack_feedback_channel = System.get_env("SLACK_FEEDBACK_CHANNEL")

config :deep_thought, :slack,
  bot_token: slack_bot_token,
  feedback_channel: slack_feedback_channel,
  signing_secret: slack_signing_secret
