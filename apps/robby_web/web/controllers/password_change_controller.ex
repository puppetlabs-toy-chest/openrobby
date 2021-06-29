defmodule RobbyWeb.PasswordChangeController do
  use RobbyWeb.Web, :controller
  alias RobbyWeb.PasswordPolicy
  alias RobbyWeb.User
  alias RobbyWeb.Plugs.FindLdapUser
  alias RobbyWeb.Plugs.EffectivePolicy
  alias RobbyWeb.ErrorHandler
  require Logger

  plug(:find_user)
  plug(FindLdapUser)
  plug(EffectivePolicy)

  def find_user(conn, _) do
    user = Repo.get(User, conn.assigns.current_user.id)
    assign(conn, :repo_user, user)
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [
      conn,
      conn.params,
      [conn.assigns.repo_user, conn.assigns.current_user]
    ])
  end

  def index(conn, _, [_repo_user, _current_user]) do
    render(conn, "index.html")
  end

  defp handle_response(conn, :ok), do: conn

  defp handle_response(conn, reason) do
    conn
    |> ErrorHandler.fail(reason)
    |> render("index.html")
  end

  defp update_salt(conn, repo_user) do
    {salt_message, changeset} =
      repo_user
      |> User.changeset(%{"salt" => User.generate_new_salt()})
      |> Repo.update()

    if salt_message == :error do
      Logger.error("Failed to update user's salt. Connection info:\n#{conn}")
    end

    changeset
  end

  def create(
        conn,
        %{
          "password_change" => %{
            "new_password" => new_password,
            "old_password" => old_password,
            "confirm_new_password" => new_password
          }
        },
        [repo_user, _current_user]
      ) do
    PasswordPolicy.passes?(conn.assigns.max_effective_policy, new_password)
    |> case do
      {:error, reason} ->
        handle_response(conn, reason)

      :ok ->
        case LdapWrite.Worker.change_password_as_user(
               conn.assigns.ldap_user.dn,
               new_password,
               old_password
             ) do
          {:error, reason} ->
            handle_response(conn, reason)

          :ok ->
            changeset = update_salt(conn, repo_user)

            conn
            |> RobbyWeb.Auth.login(changeset)
            |> put_flash(:info, "Successfully changed password!")
            |> redirect(to: page_path(conn, :index))
        end
    end
  end

  def create(
        conn,
        %{
          "password_change" => %{
            "new_password" => _new_password,
            "old_password" => _old_password,
            "confirm_new_password" => _confirm_new_password
          }
        },
        [_repo_user, _current_user]
      ) do
    conn
    |> put_flash(:error, "Password confirmation must match")
    |> render("index.html")
  end
end
