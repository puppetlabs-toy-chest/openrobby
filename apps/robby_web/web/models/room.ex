defmodule RobbyWeb.Room do
  use RobbyWeb.Web, :model

  schema "rooms" do
    field(:name, :string)
    belongs_to(:user, RobbyWeb.User)
    has_many(:messages, RobbyWeb.Message)

    timestamps()
  end

  @required_fields ~w(name)a
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
end
