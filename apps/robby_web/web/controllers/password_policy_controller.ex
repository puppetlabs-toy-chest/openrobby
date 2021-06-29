defmodule RobbyWeb.PasswordPolicyController do
  use RobbyWeb.Web, :controller

  alias RobbyWeb.PasswordPolicy

  plug(:scrub_params, "password_policy" when action in [:create, :update])

  def index(conn, _params) do
    password_policies = Repo.all(PasswordPolicy)
    render(conn, "index.html", password_policies: password_policies)
  end

  def new(conn, _params) do
    changeset = PasswordPolicy.changeset(%PasswordPolicy{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"password_policy" => password_policy_params}) do
    changeset = PasswordPolicy.changeset(%PasswordPolicy{}, password_policy_params)

    case Repo.insert(changeset) do
      {:ok, _password_policy} ->
        conn
        |> put_flash(:info, "Password policy created successfully.")
        |> redirect(to: password_policy_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    password_policy = Repo.get!(PasswordPolicy, id)
    render(conn, "show.html", password_policy: password_policy)
  end

  def edit(conn, %{"id" => id}) do
    password_policy = Repo.get!(PasswordPolicy, id)
    changeset = PasswordPolicy.changeset(password_policy)
    render(conn, "edit.html", password_policy: password_policy, changeset: changeset)
  end

  def update(conn, %{"id" => id, "password_policy" => password_policy_params}) do
    password_policy = Repo.get!(PasswordPolicy, id)
    changeset = PasswordPolicy.changeset(password_policy, password_policy_params)

    case Repo.update(changeset) do
      {:ok, password_policy} ->
        conn
        |> put_flash(:info, "Password policy updated successfully.")
        |> redirect(to: password_policy_path(conn, :show, password_policy))

      {:error, changeset} ->
        render(conn, "edit.html", password_policy: password_policy, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    password_policy = Repo.get!(PasswordPolicy, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(password_policy)

    conn
    |> put_flash(:info, "Password policy deleted successfully.")
    |> redirect(to: password_policy_path(conn, :index))
  end
end
