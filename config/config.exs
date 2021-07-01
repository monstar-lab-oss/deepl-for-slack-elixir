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
  secret_key_base: "6a4n+/AnbDyHlOT1rYbUNdVa85/S9Egb4k55q/a54JKBihccTJDb9DHHxGUGv2LC",
  render_errors: [view: DeepThoughtWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DeepThought.PubSub,
  live_view: [signing_salt: "yBzcq+Em"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
