defmodule RobbyWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias RobbyWeb.Router.Helpers

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(RobbyWeb.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_user_and_pass(conn, user, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    ldap_user = RobbyWeb.LdapRepo.get_by(RobbyWeb.Profile, uid: user)

    cond do
      ldap_user && LdapSearch.authenticate(ldap_user.dn, given_pass) == :ok ->
        user =
          case repo.get_by(RobbyWeb.User, username: user) do
            nil ->
              RobbyWeb.User.changeset_from_ldap(ldap_user)
              |> repo.insert
              |> case do
                {:ok, user} -> user
              end

            user ->
              user
          end

        {:ok, login(conn, user)}

      ldap_user ->
        {:error, :unauthorized, conn}

      true ->
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> fetch_flash(:error)
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt
    end
  end
end
