# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ridex,
  ecto_repos: [Ridex.Repo]

# Configures the endpoint
config :ridex, RidexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fcdXshgAf8wpWBqWnv1XLIE8Bp8W+tC10flP3SMQdSjvnw6f1TDOIdPoCDz8eBaw",
  render_errors: [view: RidexWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ridex.PubSub,
  live_view: [signing_salt: "wE//qhbz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
