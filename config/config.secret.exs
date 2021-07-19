use Mix.Config

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
