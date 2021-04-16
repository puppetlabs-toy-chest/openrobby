defmodule RobbyWeb.Directory do
  use RobbyWeb.Web, :model
  import RobbyWeb.Gettext
  alias RobbyWeb.ProfileHelper

  # Required_fields: [:dn]
  # Optional_fields: [:cn, :displayName, :objectClass, :title, :uid]

  @primary_key {:dn, :string, autogenerate: false}
  schema "users" do
    field(:cn, :string)
    field(:displayName, :string)
    field(:employeeNumber, :string)
    field(:objectClass, {:array, :string})
    field(:title, :string)
    field(:uid, :string)
    field(:pwdChangedTime, :string)
    field(:startDate, :naive_datetime)
  end

  gettext("cn")
  gettext("displayName")
  gettext("objectClass")
  gettext("title")
  gettext("uid")

  def orgPeople do
    ProfileHelper.orgPeople(RobbyWeb.Directory)
  end
end
