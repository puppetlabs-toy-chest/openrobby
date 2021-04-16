ExUnit.start
ExUnit.configure exclude: [admin: true, ldap: true]

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.Sandbox.mode(RobbyWeb.Repo, :manual)

