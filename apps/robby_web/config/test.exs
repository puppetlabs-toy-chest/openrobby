use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :robby_web, RobbyWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Set a higher stacktrace during test
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :robby_web, RobbyWeb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: :erlang.element(1, System.cmd("whoami", [])) |> String.trim(),
  password: "postgres",
  database: "robby_web_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :robby_web, RobbyWeb.LdapRepo,
  ldap_api: RobbyWeb.Ldap.Adapter.Sandbox,
  adapter: Ecto.Ldap.Adapter,
  hostname: "ldap.example.com",
  base: "dc=example,dc=com",
  port: 636,
  ssl: true,
  user_dn: "CHANGE_USER_DN",
  password: "CHANGE_PASSWORD",
  pool_size: 1

config :ex_aws,
  adapter: RobbyWeb.ExAws.Sandbox,
  s3_adapter: ExAws.S3

# Import dependent project configuration
import_config "../../ldap_wrapper/config/#{Mix.env()}.exs"
import_config "../../ldap_write/config/#{Mix.env()}.exs"
import_config "../../ldap_search/config/#{Mix.env()}.exs"
