defmodule RobbyWeb.NameGame do
  use RobbyWeb.Web, :model
  require Ecto.Query
  alias RobbyWeb.Repo

  @required_fields [:player_id, :correct_answer]
  @optional_fields [:chosen_answer, :options]

  schema "name_games" do
    field(:player_id, :integer)
    field(:correct_answer, :string)
    field(:correct_answer_uid, :string)
    field(:chosen_answer, :string)
    field(:options, {:array, :string})
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

  def recent_guesses(player_id) do
    Ecto.Query.from(turn in __MODULE__,
      where: turn.player_id == ^player_id and turn.correct_answer == turn.chosen_answer,
      select: turn.correct_answer,
      order_by: [desc: turn.updated_at],
      limit: 100
    )
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                                                                           #
  # TODO: This entire method must be refactored.                              #
  #                                                                           #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def people_pool(model) do
    not_allowed = recent_guesses(model.player_id) |> Repo.all()

    query =
      Ecto.Query.from(u in RobbyWeb.Directory.orgPeople(),
        select: %{cn: u.cn}
      )

    for cn <- [model.correct_answer | not_allowed] do
      query =
        Ecto.Query.from(u in query,
          where: u.cn != ^cn
        )
    end

    query
  end

  def next_right_answer(player_id) do
    not_allowed = recent_guesses(player_id) |> Repo.all()

    query =
      Ecto.Query.from(u in RobbyWeb.Profile,
        where:
          "orgPerson" in u.objectClass and not is_nil(u.employeeNumber) and
            not is_nil(u.jpegPhoto),
        select: %{cn: u.cn, uid: u.uid}
      )

    Enum.reduce(not_allowed, query, fn person, query ->
      Ecto.Query.from(u in query, where: u.cn != ^person)
    end)
  end

  def all_time_plays_for_user(player_id) do
    Ecto.Query.from(turn in __MODULE__,
      where: turn.player_id == ^player_id
    )
  end
end
