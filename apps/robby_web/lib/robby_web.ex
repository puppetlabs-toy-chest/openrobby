defmodule RobbyWeb do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(RobbyWeb.Endpoint, []),
      # Start the Ecto repository
      worker(RobbyWeb.Repo, []),
      worker(RobbyWeb.LdapRepo, []),
      worker(
        ConCache,
        [
          [
            ttl_check: :timer.minutes(1),
            ttl: :timer.minutes(15)
          ],
          [name: :password_reset]
        ],
        id: :password_reset
      ),
      worker(
        ConCache,
        [
          [
            ttl_check: :timer.minutes(15),
            ttl: :timer.hours(4)
          ],
          [name: :full_company_employee_ids]
        ],
        id: :full_company_employee_ids
      )
      # Here you could define other workers and supervisors as children
      # worker(RobbyWeb.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RobbyWeb.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)
    initialize_repos()
    {:ok, pid}
  end

  def initialize_repos() do
    Application.get_env(:robby_web, RobbyWeb.LdapRepo)
    |> Keyword.get(:ldap_api)
    |> test_ldap()

    migrate()
  end

  def test_ldap(RobbyWeb.Ldap.Adapter.Sandbox), do: :ok

  def test_ldap(_ldap_api) do
    dn = RobbyWeb.LdapRepo.config()[:user_dn]

    try do
      if nil == RobbyWeb.LdapRepo.get_by(RobbyWeb.Profile, dn: dn) do
        exit("Could not find connection DN '#{dn}' in LDAP")
      end
    rescue
      e in MatchError -> exit("Error finding connection DN '#{dn}' in LDAP: #{inspect(e)}")
    end
  end

  def migrate() do
    path = Application.app_dir(:robby_web, "priv/repo/migrations")
    Ecto.Migrator.run(RobbyWeb.Repo, path, :up, all: true)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RobbyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
