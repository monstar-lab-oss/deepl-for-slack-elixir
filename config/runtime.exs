import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if config_env() == :prod do
  deepl_auth_key =
    System.get_env("DEEPL_AUTH_KEY") ||
      raise "environment variable DEEPL_AUTH_KEY is missing."

  config :deep_thought, :deepl, auth_key: deepl_auth_key

  slack_bot_token =
    System.get_env("SLACK_BOT_TOKEN") ||
      raise "environment variable SLACK_BOT_TOKEN is missing."

  slack_signing_secret =
    System.get_env("SLACK_SIGNING_SECRET") ||
      raise "environment variable SLACK_SIGNING_SECRET is missing."

  slack_feedback_channel = System.get_env("SLACK_FEEDBACK_CHANNEL")

  config :deep_thought, :slack,
    bot_token: slack_bot_token,
    feedback_channel: slack_feedback_channel,
    signing_secret: slack_signing_secret

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :deep_thought, DeepThought.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  hostname =
    System.get_env("HOSTNAME") ||
      raise "environment variable HOSTNAME is missing."

  config :deep_thought, DeepThoughtWeb.Endpoint,
    url: [host: hostname, port: 80],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base,
    cache_static_manifest: "priv/static/cache_manifest.json",
    server: true
end
