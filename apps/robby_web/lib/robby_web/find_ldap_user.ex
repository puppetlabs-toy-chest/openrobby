defmodule RobbyWeb.Plugs.FindLdapUser do
  import Plug.Conn
  import Phoenix.Controller, only: [action_name: 1]
  require Logger

  def init(opts),
    do: Keyword.get(opts, :only, [:show, :edit, :update, :create, :delete, :index, :new])

  def call(conn, opts) when is_list(opts) do
    if action_name(conn) in opts do
      call(conn, conn.params)
    else
      conn
    end
  end

  def call(conn, %{"password_reset" => %{"email" => email}}) do
    assign(conn, :ldap_user, ldap_user_from_email(email))
  end

  def call(%Plug.Conn{assigns: %{email: email}} = conn, _) do
    assign(conn, :ldap_user, ldap_user_from_email(email))
  end

  def call(%Plug.Conn{assigns: %{repo_user: repo_user}} = conn, _) do
    assign(conn, :ldap_user, ldap_user_from_email(repo_user.email))
  end

  defp ldap_user_from_email(nil), do: nil

  defp ldap_user_from_email(email) do
    Logger.debug("Looking for LDAP user with email #{email}")
    RobbyWeb.LdapRepo.get_by(RobbyWeb.Profile, mail: email)
  end
end
