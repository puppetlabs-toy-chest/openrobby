defmodule RobbyWeb.SearchChannel do
  use Phoenix.Channel
  require Ecto.Query

  def join("search:directory", _message, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    results =
      RobbyWeb.Profile.orgPeople
      |> Ecto.Query.from
      |> build_query_from_search_terms(body)
      |> Ecto.Query.select([u], u.uid)
      |> RobbyWeb.LdapRepo.all
      |> Enum.map(&String.replace(&1, ".", "_"))
    push socket, "new_msg", %{body: results}
    {:noreply, socket}
  end

  def advanced_query?(search_terms), do: String.match?(search_terms, ~r/:/)

  def build_query_from_search_terms(queryable, search_terms) do
    search_terms
    |> advanced_query?
    |> build_query_from_search_terms(queryable, search_terms)
  end

  def build_query_from_search_terms(false, queryable, search_terms) do
    queryable
    |> Ecto.Query.where([u], like(u.cn, ^search_terms))
  end
  def build_query_from_search_terms(true, queryable, search_terms) do
    for pair <- String.split(search_terms) do
      [attr, value] = String.split(pair, ":")
      %Ecto.Query.QueryExpr{expr: {:like, [], [{{:., [], [{:&, [], [0]}, String.to_existing_atom(attr)]}, [], []}, value]}}
    end
    |> Enum.reduce(queryable, fn (expr, query) -> Ecto.Query.Builder.Filter.apply(query, :where, expr) end)
  end

end
