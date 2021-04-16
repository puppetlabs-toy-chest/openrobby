defmodule RobbyWeb.Plugs.EffectivePolicy do
  import Plug.Conn
  import Phoenix.Controller#, only: [action_name: 1]
  import Ecto.Query
  alias RobbyWeb.Repo
  alias RobbyWeb.PasswordPolicy

 def init(opts), do: Keyword.get(opts, :only, [:show, :edit, :update, :create, :delete, :index, :new])

  def call(conn, opts) do
    if action_name(conn) in opts do
      case conn.assigns.ldap_user do
        nil -> conn
        user ->
          policy = user
          |> all_policies_query
          |> Repo.all
          |> PasswordPolicy.max_effective_policy
          assign(conn, :max_effective_policy, policy)
      end
    else
      conn
    end
  end

  def all_policies_query(nil) do
    nil
  end
  def all_policies_query(ldap_user) do
    from p in PasswordPolicy,
    where: p.object_class in ^ldap_user.objectClass,
    select: p
  end
end
