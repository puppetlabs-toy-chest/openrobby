# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :robby_web, ecto_repos: [
  RobbyWeb.Repo
]

# Configures the endpoint
config :robby_web, RobbyWeb.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "your_secret_hash",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: RobbyWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
import_config "../../ldap_wrapper/config/#{Mix.env}.exs"
import_config "../../ldap_write/config/#{Mix.env}.exs"
import_config "../../ldap_search/config/#{Mix.env}.exs"
import_config "../../sms_code/config/#{Mix.env}.exs"
