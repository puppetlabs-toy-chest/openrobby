defmodule RobbyWeb.PasswordResetController do
  use RobbyWeb.Web, :controller
  alias RobbyWeb.User
  alias RobbyWeb.PasswordPolicy
  alias RobbyWeb.Emailer
  alias RobbyWeb.Plugs.FindLdapUser
  alias RobbyWeb.Plugs.EffectivePolicy
  alias RobbyWeb.ErrorHandler
  require Logger

  plug :find_email
  plug FindLdapUser, only: [:show, :edit, :update, :create]
  plug :find_repo_user, only: [:show, :edit, :update, :create]
  plug :validate_token, expiry: 15*60, only: [:show, :edit, :update]
  plug EffectivePolicy, only: [:show, :edit, :update, :create]

  defp find_email(conn, _) do
    conn.params["id"]
    |> case do
      nil -> assign(conn, :email, nil)
      id ->
        email =
          ConCache.get(:password_reset, id)
          |> Map.get(:email)
        assign(conn, :email, email)
    end
  end

  defp repo_user_from_email(email, conn) do
    email
    |> find_repo_user_by_email
    |> handle_repo_user(conn)
  end

  defp find_repo_user_by_email(nil), do: nil
  defp find_repo_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  defp handle_repo_user(nil, conn) do
    conn.assigns.ldap_user
    |> User.changeset_from_ldap
    |> Repo.insert
    |> case do
      {:ok, user} -> user
      _ -> nil
    end
  end
  defp handle_repo_user(user, _), do: user

  defp find_repo_user(conn, opts) do
    actions = Keyword.get(opts, :only, [:show, :edit, :update, :create, :new, :index, :delete])
    if action_name(conn) in actions do
      create_repo_user_if_needed(conn, conn.params)
    else
      conn
    end
  end
  defp create_repo_user_if_needed(conn, %{"password_reset" => %{"email" => email}}) do
    user = repo_user_from_email(email, conn)
    assign(conn, :repo_user, user)
  end
  defp create_repo_user_if_needed(conn, _) do
    user = repo_user_from_email(conn.assigns.email, conn)
    assign(conn, :repo_user, user)
  end

  defp validate_token(conn, opts) do
    actions = Keyword.get(opts, :only, [:show, :edit, :update, :delete])

    if action_name(conn) in actions do
      expiry = Keyword.get(opts, :expiry, 15*60)
      token =
        ConCache.get(:password_reset, conn.params["id"])
        |> Map.get(:token)
      Phoenix.Token.verify(conn, conn.assigns.repo_user.salt, token, max_age: expiry)
      |> case do
        {:ok, data} ->
          assign(conn, :token_data, data)
        {:error, :expired} ->
          conn
          |> put_flash(:error, "Reset link expired. Please try again")
          |> render("new.html")
        {:error, :invalid} ->
          conn
          |> put_flash(:error, "Invalid reset link.")
          |> render("new.html")
      end
    else
      conn
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns])
  end

  def index(conn, _, _) do
    render conn, "new.html"
  end

  def new(conn, _, _) do
    render conn, "new.html"
  end

  def create(conn, _, %{ldap_user: nil}) do
    conn
    |> assign(:reset_link, "")
    |> render("reset_sent.html")
  end

  def create(conn, %{"password_reset" => %{"email" => email}}, assigns) do
    Logger.debug("We got a password reset request for #{email}")
    token = Phoenix.Token.sign(conn, assigns.repo_user.salt, assigns.ldap_user)
    reset_id = new_reset_link_id()

    ConCache.put(:password_reset, reset_id, %{token: token, email: email})

    link = password_reset_url(conn, :show, reset_id)
    Emailer.send_reset_link(email, link)

    conn
    |> render("reset_sent.html")
  end

  defp new_reset_link_id do
    :crypto.hash(:sha256, :crypto.strong_rand_bytes(256))
    |> Base.encode16
  end

  def show(conn, %{"id" => id}, assigns) do
    assigns.ldap_user
    |> Map.get(:mobile, [])
    |> case do
      nil ->
        ConCache.update(:password_reset, id, fn (state) -> {:ok, Map.put(state, :need_2fa?, false)} end)
        render(conn, "edit.html")
      _ ->
        ConCache.update(:password_reset, id, fn (state) -> {:ok, Map.put(state, :need_2fa?, true)} end)
        conn
        |> redirect(to: password_reset_sms_code_path(conn, :index, id))
    end
  end

  def edit(conn, %{"id" => id}, _) do
    need =
      ConCache.get(:password_reset, id)
      |> Map.get(:need_2fa?)
    have =
      ConCache.get(:password_reset, id)
      |> Map.get(:have_2fa?)

    cond do
      !need -> render(conn, "edit.html")
      need && have -> render(conn, "edit.html")
      need && !have -> redirect(conn, to: password_reset_sms_code_path(conn, :index, id))
    end
  end

  def update(conn, %{"password_reset" => %{"new_password" => new_password, "confirm_new_password" => new_password}}, assigns) do
    # here's where we'll do password validation
    assigns.max_effective_policy
    |> PasswordPolicy.passes?(new_password)
    |> case do
      {:error, reason} -> ErrorHandler.fail(conn,reason) |> render("edit.html")
      :ok ->
        LdapWrite.Worker.write_password(assigns.ldap_user.dn, new_password)
        |> case do
          {:error, reason} ->
            conn
            |> put_flash(:error, reason)
            |> render("edit.html")
          :ok ->
            {salt_message, changeset} = assigns.repo_user
            |> User.changeset(%{"salt" => User.generate_new_salt})
            |> Repo.update
            if salt_message == :error do
              Logger.error "Failed to update user's salt. Connection info:\n#{inspect conn}"
            end
            conn
            |> RobbyWeb.Auth.login(changeset)
            |> put_flash(:info, "Successfully reset your password!")
            |> redirect(to: page_path(conn, :index))
        end
    end
  end

  def update(conn, %{"password_reset" => %{"new_password" => _new_password, "confirm_new_password" => _confirm_new_password}}, _assigns) do
    conn
    |> put_flash(:error, "Password and confirmation must match")
    |> render("edit.html")
  end
end
