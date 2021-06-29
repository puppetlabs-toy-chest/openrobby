defmodule RobbyWeb.ProfileHelper do
  @moduledoc """
  Helper functions for Profile and Directory
  """
  require Ecto.Query

  def orgPeople(type) do
    Ecto.Query.from(u in type,
      where:
        "exOrgContractor" not in u.objectClass and
          "exOrgPerson" not in u.objectClass and
          (("orgPerson" in u.objectClass and
              not is_nil(u.employeeNumber) and
              not is_nil(u.startDate)) or
             "orgContractor" in u.objectClass)
    )
  end
end
