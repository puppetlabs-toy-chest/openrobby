defmodule RobbyWeb.NameGameController do
  use RobbyWeb.Web, :controller
  alias RobbyWeb.NameGame
  alias RobbyWeb.Profile
  alias RobbyWeb.LdapRepo

  plug :calculate_score when action in [:show]
  plug :random_seed when action in [:new]

  def new(conn, _) do
    game = create_new_game(conn)

    redirect(conn, to: name_game_path(conn, :show, game))
  end

  def show(conn, %{"id" => id}) do
    game = Repo.get(NameGame, id)

    if game.player_id == conn.assigns.current_user.id do
      profile = LdapRepo.get_by(Profile, uid: game.correct_answer_uid)
      render(conn, "show.html", game: game, changeset: NameGame.changeset(game), profile: profile)
    else
      conn
      |> put_flash(:error, "That's someone else's game, sorry! Here's a new one for you.")
      |> redirect(to: name_game_path(conn, :new))
    end
  end

  def update(conn, %{"id" => id, "name_game" => params}) do
    game =
      Repo.get(NameGame, id)
      |> NameGame.changeset(params)
      |> Repo.update!
    conn
    |> display_answer(game)
    |> redirect(to: name_game_path(conn, :new))
  end

  # catches the case where user doesn't push a button
  def update(conn, %{"id" => id}) do
    game = Repo.get(NameGame, id)
    conn
    |> put_flash(:warning, "Please choose a name")
    |> redirect(to: name_game_path(conn, :show, game))
  end

  def display_answer(conn, %NameGame{correct_answer: answer, chosen_answer: answer}) do
    conn
    |> put_flash(:success, "You are correct.")
  end
  def display_answer(conn, game) do
    conn
    |> put_flash(:error, "That's wrong! The correct answer was #{game.correct_answer}.")
  end

  defp create_new_game(conn) do
    answer =
      RobbyWeb.NameGame.next_right_answer(conn.assigns.current_user.id)
      |> RobbyWeb.LdapRepo.all
      |> Enum.random
    %NameGame{correct_answer: answer.cn, correct_answer_uid: answer.uid, player_id: conn.assigns.current_user.id}
      |> add_randos
      |> Ecto.Changeset.apply_changes
      |> Repo.insert!
  end

  defp add_randos(game) do
    randos =
      NameGame.people_pool(game)
      |> LdapRepo.all
      |> Enum.take_random(5)
      |> Enum.map(fn person -> person.cn end)
    NameGame.changeset(game, %{options: randos})
  end

  defp calculate_score(conn, _) do
		{wins, total} =
			conn.assigns.current_user.id
			|> RobbyWeb.NameGame.all_time_plays_for_user
			|> Ecto.Query.where([turn], not is_nil(turn.chosen_answer))
			|> Ecto.Query.select([turn], {sum(fragment("case when chosen_answer = correct_answer then 1 else 0 end")), count(turn.id)})
			|> RobbyWeb.Repo.one

    if total == 0 do
      assign(conn, :score, nil)
    else
      assign(conn, :score, Float.round(wins / total * 100, 2))
    end
  end

  def leaderboard(conn, _) do
    top_10_ref = Task.async(fn -> get_leaderboard_stat(:top_10_most_correct) end)
    most_accurate_ref = Task.async(fn -> get_leaderboard_stat(:top_10_most_accurate) end)
    most_correctly_guessed_ref = Task.async(fn -> get_leaderboard_stat(:most_recognizable) end)
    top_10 = Task.await(top_10_ref)
    most_accurate = Task.await(most_accurate_ref)
    most_correctly_guessed = Task.await(most_correctly_guessed_ref)

    render(conn, "leaderboard.html", top: top_10, recognizable: most_correctly_guessed, accurate: most_accurate)
  end

  def get_leaderboard_stat(atom) when is_atom(atom) do
    unprocessed = apply(__MODULE__, atom, [])
    map = retrieve_uid_and_cn(unprocessed)
    Enum.map(unprocessed, &sub_with_map_value(&1, map))
  end

  def sub_with_map_value({a, b, c}, map), do: {a, b, Map.get(map, c)}
  def sub_with_map_value({a, b}, map), do: {a, Map.get(map, b)}

  def retrieve_uid_and_cn([tuple|_] = list) do
    query_params =
      list
      |> Enum.map(&elem(&1, tuple_size(tuple) - 1))
    ldap_uid_name_query(query_params, tuple_size(tuple))
    |> RobbyWeb.LdapRepo.all
    |> Enum.into(%{})
  end

  def ldap_uid_name_query(params, 3) do
    Ecto.Query.from(u in RobbyWeb.Profile,
                    where: u.mail in ^params,
                    select: {u.mail, {u.uid, u.cn}})
  end
  def ldap_uid_name_query(params, 2) do
    Ecto.Query.from(u in RobbyWeb.Profile,
                    where: u.uid in ^params,
                    select: {u.uid, {u.uid, u.cn}})
  end


  def top_10_most_correct do
    Ecto.Query.from(RobbyWeb.NameGame)
    |> Ecto.Query.where([turn], not is_nil(turn.chosen_answer))
    |> Ecto.Query.join(:inner, [turn], user in RobbyWeb.User, turn.player_id == user.id)
    |> Ecto.Query.select([turn, user], {sum(fragment("case when chosen_answer = correct_answer then 1 else 0 end")), count(turn.id), user.username})
    |> Ecto.Query.group_by([turn, user], user.username)
    |> Ecto.Query.order_by([turn, user], [desc: sum(fragment("case when chosen_answer = correct_answer then 1 else 0 end")), asc: count(turn.id)])
    |> Ecto.Query.limit(10)
    |> RobbyWeb.Repo.all
  end

  def most_recognizable do
    Ecto.Query.from(n in RobbyWeb.NameGame,
      where: n.chosen_answer == n.correct_answer,
      group_by: n.correct_answer_uid,
      order_by: [desc: count(n.id)],
      select: {count(n.id), n.correct_answer_uid},
      limit: 10)
    |> RobbyWeb.Repo.all
  end

  def top_10_most_accurate do
    Ecto.Query.from(RobbyWeb.NameGame)
    |> Ecto.Query.where([turn], not is_nil(turn.chosen_answer))
    |> Ecto.Query.join(:inner, [turn], user in RobbyWeb.User, turn.player_id == user.id)
    |> Ecto.Query.select([turn, user], {fragment("round(sum(case when correct_answer=chosen_answer then 1 else 0 end) * 100.0 / count(*), 2) as percent"), count(turn.id), user.username})
    |> Ecto.Query.group_by([turn, user], user.username)
    |> Ecto.Query.order_by([turn, user], [desc: fragment("percent"), desc: count(turn.id)])
    |> Ecto.Query.limit(10)
    |> RobbyWeb.Repo.all
  end

  def random_seed(conn, _) do
    :rand.normal()
    conn
  end
end
