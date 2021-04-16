defmodule RobbyWeb.SessionController do
  use RobbyWeb.Web, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"user" => user, "password" => pass}}) do
    user = Enum.at(String.split(user, "@"), 0)

    case RobbyWeb.Auth.login_by_user_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: page_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination: use your organization login")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> RobbyWeb.Auth.logout()
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: page_path(conn, :index))
  end
end
