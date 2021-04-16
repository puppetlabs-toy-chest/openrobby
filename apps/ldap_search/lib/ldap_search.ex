defmodule LdapSearch do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(LdapSearch.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LdapSearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def find_by_email(email, attributes \\ [:dn, :objectClass, :mail, :mobile]) do
    LdapSearch.Worker.find_by_email(email, attributes)
  end

  def authenticate(dn, password) do
    LdapSearch.Worker.authenticate(dn, password)
  end
end
