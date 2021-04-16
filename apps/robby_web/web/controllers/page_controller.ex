defmodule RobbyWeb.PageController do
  use RobbyWeb.Web, :controller

  def index(conn = %{assigns: %{current_user: user}}, params) when not is_nil(user) do
    orgPeople =
      RobbyWeb.Directory.orgPeople
      |> RobbyWeb.LdapRepo.all
      |> sort_directory(params)
      |> reverse_if_necessary(params)
    render conn, "index.html", users: orgPeople
  end

  def index(conn, _params) do
    render conn, "index.html", users: []
  end

  def about(conn, _params) do
    render conn, "about.html", robby_version: get_robby_version()
  end

  defp get_robby_version() do
    Application.loaded_applications
    |> Enum.filter(fn {app, _title, _version} = entry -> app == :robby_web end)
    |> hd
    |> elem(2)
  end

  def password_hall_of_shame(conn, _) do
    {:ok, pid} = StringIO.open("")
    :io.fwrite(pid, '~4..0w~2..0w~i01000000Z', Tuple.to_list(substract_3_months(:erlang.date)))
    timestamp = StringIO.flush(pid)
    StringIO.close(pid)
    orgPeople =
      Ecto.Query.from(u in RobbyWeb.Directory.orgPeople,
        where: is_nil(u.pwdChangedTime) or u.pwdChangedTime <= ^timestamp)
      |> RobbyWeb.LdapRepo.all
      |> Enum.group_by(fn u -> String.slice(u.pwdChangedTime, 0, 6) end)
    render conn, "password_hall_of_shame.html", users: orgPeople
  end

  defp substract_3_months({year, month, date}) when month <= 3, do: {year - 1, month + 9, date}
  defp substract_3_months({year, month, date}), do: {year, month - 3, date}

  defp reverse_if_necessary(people, %{"sort_reverse" => "true"}), do: Enum.reverse(people)
  defp reverse_if_necessary(people, params) do
    params
    |> Map.has_key?("sort_reverse")
    |> case do
      true -> people
      _ -> Enum.reverse(people)
    end
  end

  defp sort_directory(people, %{"sort_by" => "startDate"}), do: Enum.sort_by(people, &(&1.startDate))
  defp sort_directory(people, %{"sort_by" => sort_by}), do: Enum.sort_by(people, &Map.get(&1, String.to_existing_atom(sort_by)))
  defp sort_directory(people, _), do: Enum.sort_by(people, &(&1.startDate))
end
