defmodule RobbyWeb.ProfileControllerTest do
  use RobbyWeb.ConnCase
  alias RobbyWeb.User

  setup do
    {:ok, conn: build_conn()}
  end

  test "should not render profile page if not logged in", %{conn: conn} do
    conn = get conn, profile_path(conn, :show, 1)
    assert html_response(conn, 302) =~ "redirected"
    assert get_flash(conn, :error) =~ "You must be logged in"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  @tag ldap: true
  test "should render profile page if valid id", %{conn: conn} do
    Repo.insert!(%User{username: "tom@example.com"})
    result =
      conn
      |> post(session_path(conn, :create), %{"session" => %{"email" => "tom@example.com", "password" => "cattbutt"}})
      |> fetch_session
      |> get(profile_path(conn, :show, "tom"))
      |> html_response(200)

    assert result =~ "tom"
  end
end
