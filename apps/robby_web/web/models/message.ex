defmodule RobbyWeb.Message do
  use RobbyWeb.Web, :model
  @derive {Poison.Encoder, only: [:user_id, :room_id, :body, :inserted_at]}

  @required_fields [:body, :user_id, :room_id]
  @optional_fields []

  schema "messages" do
    belongs_to(:user, RobbyWeb.User)
    belongs_to(:room, RobbyWeb.Room)

    field(:body, :string)

    timestamps()
  end

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
