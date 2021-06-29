defmodule RobbyWeb.ProfileTest do
  use RobbyWeb.ModelCase

  alias RobbyWeb.Profile

  @attrs %{
    displayName: "some content",
    employeeType: "some content",
    interestingFact: "allergic to coffee; owns 18 bicycles"
  }

  test "changeset with valid attributes" do
    changeset = Profile.changeset(%Profile{objectClass: "orgPerson", dn: "my_dn"}, @attrs)
    assert changeset.valid?
  end
end
