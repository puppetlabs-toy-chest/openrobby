defmodule RobbyWeb.UserControllerTest do
  use RobbyWeb.ConnCase

  alias RobbyWeb.User
  @valid_attrs %{dn: "some content", salt: "some content", username: "some content"}
  @invalid_attrs %{}

  setup do
    {:ok, conn: build_conn()}
  end

  @tag admin: true
  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, user_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing users"
  end

  @tag admin: true
  test "renders form for new resources", %{conn: conn} do
    conn = get(conn, user_path(conn, :new))
    assert html_response(conn, 200) =~ "New user"
  end

  @tag admin: true
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @valid_attrs)
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
    assert html_response(conn, 200) =~ "New user"
  end

  @tag admin: true
  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert!(%User{})
    conn = get(conn, user_path(conn, :show, user))
    assert html_response(conn, 200) =~ "Show user"
  end

  @tag admin: true
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, user_path(conn, :show, -1))
    end
  end

  @tag admin: true
  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert!(%User{})
    conn = get(conn, user_path(conn, :edit, user))
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = Repo.insert!(%User{})
    conn = put(conn, user_path(conn, :update, user), user: @valid_attrs)
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert!(%User{})
    conn = put(conn, user_path(conn, :update, user), user: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert!(%User{})
    conn = delete(conn, user_path(conn, :delete, user))
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
