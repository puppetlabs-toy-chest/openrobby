defmodule RobbyWeb.NameGameTest do
  use RobbyWeb.ModelCase

  alias RobbyWeb.NameGame

  @valid_attrs %{chosen_answer: "My Name"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = NameGame.changeset(%NameGame{correct_answer: "My Name", player_id: "1"}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = NameGame.changeset(%NameGame{}, @invalid_attrs)
    refute changeset.valid?
  end
end
