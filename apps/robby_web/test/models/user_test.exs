defmodule RobbyWeb.UserTest do
  use RobbyWeb.ModelCase

  alias RobbyWeb.User

  @valid_attrs %{
    dn: "some content",
    salt: "some content",
    username: "some content",
    email: "superawesome@example.com"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
