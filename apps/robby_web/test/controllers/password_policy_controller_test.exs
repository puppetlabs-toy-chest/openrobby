defmodule RobbyWeb.PasswordPolicyControllerTest do
  use RobbyWeb.ConnCase

  alias RobbyWeb.PasswordPolicy
  @valid_attrs %{min_char_classes: 42, min_length: 42, object_class: "some content"}
  @invalid_attrs %{}

  setup do
    {:ok, conn: build_conn()}
  end

  @tag admin: true
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, password_policy_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing password policies"
  end

  @tag admin: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, password_policy_path(conn, :new)
    assert html_response(conn, 200) =~ "New password policy"
  end

  @tag admin: true
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, password_policy_path(conn, :create), password_policy: @valid_attrs
    assert redirected_to(conn) == password_policy_path(conn, :index)
    assert Repo.get_by(PasswordPolicy, @valid_attrs)
  end

  @tag admin: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, password_policy_path(conn, :create), password_policy: @invalid_attrs
    assert html_response(conn, 200) =~ "New password policy"
  end

  @tag admin: true
  test "shows chosen resource", %{conn: conn} do
    password_policy = Repo.insert! %PasswordPolicy{}
    conn = get conn, password_policy_path(conn, :show, password_policy)
    assert html_response(conn, 200) =~ "Show password policy"
  end

  @tag admin: true
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, password_policy_path(conn, :show, -1)
    end
  end

  @tag admin: true
  test "renders form for editing chosen resource", %{conn: conn} do
    password_policy = Repo.insert! %PasswordPolicy{}
    conn = get conn, password_policy_path(conn, :edit, password_policy)
    assert html_response(conn, 200) =~ "Edit password policy"
  end

  @tag admin: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    password_policy = Repo.insert! %PasswordPolicy{}
    conn = put conn, password_policy_path(conn, :update, password_policy), password_policy: @valid_attrs
    assert redirected_to(conn) == password_policy_path(conn, :show, password_policy)
    assert Repo.get_by(PasswordPolicy, @valid_attrs)
  end

  @tag admin: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    password_policy = Repo.insert! %PasswordPolicy{}
    conn = put conn, password_policy_path(conn, :update, password_policy), password_policy: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit password policy"
  end

  @tag admin: true
  test "deletes chosen resource", %{conn: conn} do
    password_policy = Repo.insert! %PasswordPolicy{}
    conn = delete conn, password_policy_path(conn, :delete, password_policy)
    assert redirected_to(conn) == password_policy_path(conn, :index)
    refute Repo.get(PasswordPolicy, password_policy.id)
  end
end
