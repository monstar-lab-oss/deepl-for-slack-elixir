# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :deep_thought,
  ecto_repos: [DeepThought.Repo]

# Configures the endpoint
config :deep_thought, DeepThoughtWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "02c5zaZSAEWFRKzGQI3woV+givqta4RT6oif5uWeX00saQNkdUcj/vLJJDdcwjQr",
  render_errors: [view: DeepThoughtWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DeepThought.PubSub,
  live_view: [signing_salt: "lVgWDZGI"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, adapter: Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
import_config "config.secret.exs"
