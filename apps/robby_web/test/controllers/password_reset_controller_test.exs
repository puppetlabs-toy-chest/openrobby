defmodule RobbyWeb.PasswordResetControllerTest do
  use RobbyWeb.ConnCase
  alias RobbyWeb.User
  alias RobbyWeb.PasswordPolicy

  @valid_user_no_mobile %User{
    dn: "uid=tom,ou=users,dc=example,dc=com",
    salt: "VWBjGIv1DCA2u15kaJ38w+sl4pNeH1minZz6D3ivT/0XzST2+9E0RZFoBX0iqnOF",
    username: "tom",
    email: "tom@example.com"
  }

  @valid_user_mobile %User{
    dn: "uid=jim,ou=users,dc=example,dc=com",
    salt: "salty",
    username: "jim",
    email: "jim@example.com"
  }

  @password_policy %PasswordPolicy{min_char_classes: 2, min_length: 10, object_class: "orgPerson"}

  setup do
    _password_policy = Repo.insert @password_policy
    user =  Repo.insert!(@valid_user_no_mobile)
    mobile_user = Repo.insert!(@valid_user_mobile)

    reset_cache()

    {:ok, conn: build_conn(), valid_user: user, valid_mobile: mobile_user, reset_id: new_reset_id()}
  end

  def reset_cache do
    :password_reset
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.each(fn({key, _}) -> ConCache.delete(:password_reset, key) end)
  end

  defp new_reset_id do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16
  end

  test "renders form for entering email", %{conn: conn} do
    conn = get conn, password_reset_path(conn, :index)
    assert html_response(conn, 200) =~ "Enter Email"

    conn = get conn, password_reset_path(conn, :new)
    assert html_response(conn, 200) =~ "Enter Email"
  end

  test "renders 'reset link sent' for invalid user", %{conn: conn} do
    conn = post conn, password_reset_path(conn, :create, %{"email" => "fake_email@example.com"})
    assert conn.assigns.reset_link == ""
    assert html_response(conn, 200) =~ "Reset Link Sent"
  end

  test "renders 'reset link sent' and sends link for valid user", %{conn: conn, valid_user: user} do
    conn = post conn, password_reset_path(conn, :create, %{"email" => user.email})
    assert html_response(conn, 200) =~ "Reset Link Sent"
  end

  test "link renders form for changing password if no mobile on record", %{conn: conn, valid_user: valid_user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, valid_user.salt, valid_user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: valid_user.email})
    conn = get conn, password_reset_path(conn, :show, reset_id)
    assert html_response(conn, 200) =~ "Enter new password"
  end

  test "link redirects to sms page if mobile on record", %{conn: conn, valid_mobile: user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, user.salt, user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: user.email})
    conn = get conn, password_reset_path(conn, :show, reset_id)
    assert html_response(conn, 302) =~ "redirected"
    assert redirected_to(conn) == password_reset_sms_code_path(conn, :index, reset_id)
  end

  test "edit renders the change form for users without mobile #'s", %{conn: conn, valid_user: valid_user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, valid_user.salt, valid_user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: valid_user.email})
    conn = get conn, password_reset_path(conn, :edit, reset_id)
    assert html_response(conn, 200) =~ "Enter new password"
  end

  test "edit renders the change form for users with mobile #'s who have validated 2fa", %{conn: conn, valid_mobile: valid_user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, valid_user.salt, valid_user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: valid_user.email})
    ConCache.update(:password_reset, reset_id, fn (state) -> {:ok, Map.put(state, :need_2fa?, true)} end)
    ConCache.update(:password_reset, reset_id, fn (state) -> {:ok, Map.put(state, :have_2fa?, true)} end)
    conn = get conn, password_reset_path(conn, :edit, reset_id)
    assert html_response(conn, 200) =~ "Enter new password"
  end

  test "edit redirects to sms page for users with mobile # who need to validate 2fa", %{conn: conn, valid_mobile: valid_user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, valid_user.salt, valid_user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: valid_user.email})
    ConCache.update(:password_reset, reset_id, fn (state) -> {:ok, Map.put(state, :need_2fa?, true)} end)
    ConCache.update(:password_reset, reset_id, fn (state) -> {:ok, Map.put(state, :have_2fa?, false)} end)
    conn = get conn, password_reset_path(conn, :edit, reset_id)
    assert html_response(conn, 302) =~ "redirected"
    assert redirected_to(conn) == password_reset_sms_code_path(conn, :index, reset_id)
  end

  test "updates valid users password in ldap and salt in repo if passes policy", %{conn: conn, valid_user: valid_user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, valid_user.salt, valid_user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: valid_user.email})
    conn = put conn, password_reset_path(conn, :update, reset_id, %{"password_reset" => %{"new_password" => "dagbutt123", "confirm_new_password" => "dagbutt123"}})
    assert redirected_to(conn) == page_path(conn, :index)
    assert get_flash(conn, :info) =~ "Successfully reset your password!"
  end

  test "fails to update users password if fails policy", %{conn: conn, valid_user: valid_user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, valid_user.salt, valid_user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: valid_user.email})
    conn = put conn, password_reset_path(conn, :update, reset_id, %{"password_reset" => %{"new_password" => "short", "confirm_new_password" => "short"}})
    assert html_response(conn, 200) =~ "Enter new password"
    assert get_flash(conn, :error) =~ "Password is too short"
  end

  test "fails to update users password doesn't match confirmation", %{conn: conn, valid_user: valid_user, reset_id: reset_id} do
    token = Phoenix.Token.sign(RobbyWeb.Endpoint, valid_user.salt, valid_user)
    ConCache.put(:password_reset, reset_id, %{token: token, email: valid_user.email})
    conn = put conn, password_reset_path(conn, :update, reset_id, %{"password_reset" => %{"new_password" => "notsoshort1", "confirm_new_password" => "notsoshort12"}})
    assert html_response(conn, 200) =~ "Enter new password"
    assert get_flash(conn, :error) =~ "Password and confirmation must match"
  end
end
