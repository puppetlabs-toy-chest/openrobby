defmodule RobbyWeb.User do
  use RobbyWeb.Web, :model

  schema "users" do
    field(:dn, :string)
    field(:username, :string)
    field(:salt, :string)
    field(:email, :string)

    timestamps()
  end

  @required_fields ~w(dn username salt email)a
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, List.flatten(@required_fields, @optional_fields))
    |> validate_required(@required_fields)
  end

  def changeset_from_ldap(nil) do
    %RobbyWeb.User{}
    |> changeset
  end

  def changeset_from_ldap(ldap_user) do
    %RobbyWeb.User{}
    |> changeset(%{
      :dn => ldap_user.dn,
      :username => ldap_user.uid,
      :salt => generate_new_salt(),
      :email => ldap_user.mail
    })
  end

  def generate_new_salt do
    :crypto.strong_rand_bytes(48) |> Base.encode64()
  end
end
