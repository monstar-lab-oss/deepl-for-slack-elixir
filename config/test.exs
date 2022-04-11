import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :deep_thought, DeepThought.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "deep_thought_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :deep_thought, DeepThoughtWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vpWffOaFjuR7Ctrxxplc2Kfq7UIcFhZ8hbiXpbOKYTz6vEaz0TlhH2u3u020ozLu",
  server: false

config :tesla, adapter: Tesla.Mock

# In test we don't send emails.
config :deep_thought, DeepThought.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

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
