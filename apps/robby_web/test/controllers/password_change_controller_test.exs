defmodule RobbyWeb.PasswordChangeControllerTest do
  use RobbyWeb.ConnCase
  alias RobbyWeb.User
  alias RobbyWeb.PasswordPolicy

  @valid_user %User{
    dn: "uid=jane,ou=users,dc=example,dc=com",
    salt: "VWBjGIv1DCA2u15kaJ38w+sl4pNeH1minZz6D3ivT/0XzST2+9E0RZFoBX0iqnOF",
    email: "jane@example.com",
    username: "jane"
    }
  @pass_pol %PasswordPolicy {
    min_char_classes: 2, min_length: 10, object_class: "orgPerson"
  }

  setup do
    {:ok,
     conn: build_conn(),
     repo_user: Repo.insert!(@valid_user),
     password_policy: Repo.insert!(@pass_pol)}
  end

  test "Only displays for logged in users", %{conn: conn} do
    conn = conn
    |> get(password_change_path(conn, :index))
    assert get_flash(conn, :error ) =~ "You must be logged in"
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "Displays form for logged in users", %{conn: conn} do
    conn = conn
    |> post(session_path(conn, :create), %{"session" => %{"user" => "jane", "password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    |> fetch_session
    |> get(password_change_path(conn, :index))
    assert html_response(conn, 200) =~ "Change Password"
  end

  test "updates user salt in repository for valid user", %{conn: conn, repo_user: repo_user} do
    old_salt = repo_user.salt
    conn
    |> post(session_path(conn, :create), %{"session" => %{"user" => "jane", "password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    |> fetch_session
    |> post(password_change_path(conn, :create), %{"password_change" => %{ "new_password" => "doggbuttttttt2", "confirm_new_password" => "doggbuttttttt2", "old_password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    refute Repo.get(User, repo_user.id).salt  == old_salt
  end

  test "throws error on change if invalid old password", %{conn: conn} do
    conn = conn
    |> post(session_path(conn, :create), %{"session" => %{"user" => "jane", "password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    |> fetch_session
    |> post(password_change_path(conn, :create), %{"password_change" => %{ "new_password" => "doggbuttttt2", "confirm_new_password" => "doggbuttttt2", "old_password" => "wrong_old_passw0rd"}})
    assert get_flash(conn, :error) =~ "Invalid Credentials"
  end

  test "throws error on change if new password is too short", %{conn: conn} do
    conn = conn
    |> post(session_path(conn, :create), %{"session" => %{"user" => "jane", "password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    |> fetch_session
    |> post(password_change_path(conn, :create), %{"password_change" => %{ "new_password" => "dog23", "confirm_new_password" => "dog23", "old_password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    assert get_flash(conn, :error) =~ "Password is too short,"
  end

  test "throws error on change if new password doesnt have enough char classes", %{conn: conn} do
    conn = conn
    |> post(session_path(conn, :create), %{"session" => %{"user" => "jane", "password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    |> fetch_session
    |> post(password_change_path(conn, :create), %{"password_change" => %{ "new_password" => "doggbutttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt", "confirm_new_password" => "doggbutttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt", "old_password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    assert get_flash(conn, :error) =~ "Password is too simple, "
  end

  test "throws error on change if new password does not match confirmation", %{conn: conn} do
    conn = conn
    |> post(session_path(conn, :create), %{"session" => %{"user" => "jane", "password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    |> fetch_session
    |> post(password_change_path(conn, :create), %{"password_change" => %{ "new_password" => "doggbutttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt", "confirm_new_password" => "something_else", "old_password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    assert get_flash(conn, :error) =~ "Password confirmation must match"
  end

  test "updates user password if valid", %{conn: conn} do
    conn = conn
    |> post(session_path(conn, :create), %{"session" => %{"user" => "jane", "password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    |> fetch_session
    |> post(password_change_path(conn, :create), %{"password_change" => %{ "new_password" => "doggbuttttt11", "confirm_new_password" => "doggbuttttt11", "old_password" => "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg"}})
    assert get_flash(conn, :info) =~ "Successfully changed password!"
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
