defmodule RobbyWeb.SmsCodeController do
  use RobbyWeb.Web, :controller
  require Logger

  plug(:find_token)
  plug(:find_email)
  plug(:find_ldap_user)
  plug(:find_repo_user)
  plug(:validate_token, expiry: 15 * 60)

  defp find_email(conn, _) do
    email =
      ConCache.get(:password_reset, conn.params["password_reset_id"])
      |> Map.get(:email)

    assign(conn, :email, email)
  end

  defp find_token(conn, _) do
    token =
      ConCache.get(:password_reset, conn.params["password_reset_id"])
      |> Map.get(:token)

    assign(conn, :token, token)
  end

  defp validate_token(conn, opts) do
    expiry = Keyword.get(opts, :expiry, 15 * 60)

    Phoenix.Token.verify(conn, conn.assigns.repo_user.salt, conn.assigns.token, max_age: expiry)
    |> case do
      {:ok, data} ->
        assign(conn, :token_data, data)

      {:error, :expired} ->
        conn
        |> put_flash(:error, "Reset link expired. Please try again")
        |> redirect(to: password_reset_path(conn, :new))

      {:error, :invalid} ->
        conn
        |> put_flash(:error, "Invalid reset link.")
        |> redirect(to: password_reset_path(conn, :new))
    end
  end

  defp find_ldap_user(conn, _) do
    user = RobbyWeb.LdapRepo.get_by(RobbyWeb.Profile, mail: conn.assigns.email)
    assign(conn, :ldap_user, user)
  end

  defp find_repo_user(conn, _) do
    user = Repo.get_by(RobbyWeb.User, email: conn.assigns.email)
    assign(conn, :repo_user, user)
  end

  def index(conn, _) do
    SmsCode.Generator.send_new_code(conn.assigns.token_data.dn, conn.assigns.token_data.mobile)
    render(conn, "index.html")
  end

  def create(conn, %{"password_reset_sms_code" => %{"sms_code" => sms_code}}) do
    SmsCode.Generator.validate_code(conn.assigns.token_data.dn, String.upcase(sms_code))
    |> handle_2fa_code(conn)
  end

  defp handle_2fa_code(false, conn) do
    reset_id = conn.params["password_reset_id"]

    ConCache.update(:password_reset, reset_id, fn state ->
      {:ok, Map.put(state, :have_2fa?, false)}
    end)

    conn
    |> put_flash(:error, "Wrong 2 factor auth code")
    |> render("index.html")
  end

  defp handle_2fa_code(true, conn) do
    reset_id = conn.params["password_reset_id"]

    ConCache.update(:password_reset, reset_id, fn state ->
      {:ok, Map.put(state, :have_2fa?, true)}
    end)

    conn
    |> put_flash(:info, "Code accepted, please enter a new password")
    |> redirect(to: password_reset_path(conn, :edit, reset_id))
  end
end
