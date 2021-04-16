defmodule RobbyWeb.AuthTest do
  use RobbyWeb.ConnCase
  alias RobbyWeb.Auth
  alias RobbyWeb.User
  alias RobbyWeb.Repo

  @valid_user %User{
    dn: "uid=tom,ou=users,dc=example,dc=com",
    salt: "VWBjGIv1DCA2u15kaJ38w+sl4pNeH1minZz6D3ivT/0XzST2+9E0RZFoBX0iqnOF",
    username: "tom",
    email: "tom@example.com"
  }

  setup do
    {:ok, repo_user: Repo.insert!(@valid_user)}
  end

  defp with_session(conn, user_id) do
    session_opts =
      Plug.Session.init(store: :cookie, key: "_app", encryption_salt: "abc", signing_salt: "abc")

    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session()
    |> Plug.Conn.put_session(:user_id, user_id)
  end

  test "Auth plug assigns current user from stored session", meta do
    opts = Auth.init(repo: Repo)
    conn = with_session(build_conn(), meta[:repo_user].id)
    conn = Auth.call(conn, opts)
    assert conn.assigns.current_user == meta[:repo_user]
  end

  test "Auth plug assigns current user to nil if no stored session" do
    opts = Auth.init(repo: Repo)
    conn = with_session(build_conn(), nil)
    conn = Auth.call(conn, opts)
    assert conn.assigns.current_user == nil
  end

  test "login_by_email_and pass with valid LDAP creds. returns :ok and a logged in connection",
       meta do
    # user already in Repo
    conn = with_session(build_conn(), nil)
    {resp, conn} = Auth.login_by_user_and_pass(conn, "tom", "cattbutt", repo: Repo)
    assert resp == :ok
    assert conn.assigns.current_user == meta[:repo_user]
    assert get_session(conn, :user_id) == meta[:repo_user].id
    # user not yet in Repo
    conn = with_session(build_conn(), nil)

    {resp, conn} =
      Auth.login_by_user_and_pass(
        conn,
        "jane",
        "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg",
        repo: Repo
      )

    assert resp == :ok
    assert Repo.get_by(User, username: "jane") == conn.assigns.current_user
    assert conn.assigns.current_user.id == get_session(conn, :user_id)
  end

  test "login_by_email_and_pass with invalid LDAP creds does not add a user to the session" do
    conn = with_session(build_conn(), nil)

    assert Auth.login_by_user_and_pass(conn, "jim", "g", repo: Repo) ==
             {:error, :unauthorized, conn}

    refute Repo.get_by(User, username: "nobody")
  end

  test "logout drops user info from session" do
    conn =
      with_session(build_conn(), @valid_user)
      |> Auth.login(@valid_user)
      |> Auth.logout()

    conn = get(conn, password_change_path(conn, :index))
    assert get_flash(conn, :error) =~ "You must be logged in to access that page"
    refute get_session(conn, :resp_cookies)
  end

  test "authenticate_user redirects to home page if user is not logged in" do
    conn =
      with_session(build_conn(), nil)
      |> Auth.call(RobbyWeb.Repo)
      |> Auth.authenticate_user([])

    assert get_flash(conn, :error) =~ "You must be logged in to access that page"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "authenticate_user returns conn if user is logged in", %{repo_user: repo_user} do
    conn =
      with_session(build_conn(), repo_user.id)
      |> Auth.call(RobbyWeb.Repo)

    assert Auth.authenticate_user(conn, []) == conn
  end
end
