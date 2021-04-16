defmodule RobbyWeb.ProfileView do
  use RobbyWeb.Web, :view

  @valuesOnly [:st, :l, :countryName, :stateOrProvinceName]
  @lists [:projects, :skills, :sshPublicKey, :languages, :ou]
  @links [
    :mail,
    :mobile,
    :manager,
    :steamAccount,
    :github,
    :telephoneNumber,
    :twitterHandle,
    :hasSubordinates,
    :uid
  ]
  @specificPartials [:cn, :jpegPhoto, :title, :personalTitle, :sshPublicKey]

  for key <- @specificPartials do
    def render_attribute(unquote(key), %{unquote(key) => value}) when not is_nil(value) do
      render("#{unquote(key)}_partial.html", type: unquote(key), value: value)
    end
  end

  for key <- @lists do
    def render_attribute(unquote(key), %{unquote(key) => []}), do: nil

    def render_attribute(unquote(key), %{unquote(key) => value})
        when not is_nil(value) and is_list(value) do
      render("list_partial.html", type: unquote(key), value: value)
    end
  end

  for key <- @valuesOnly do
    def render_attribute(unquote(key), %{unquote(key) => value}) when not is_nil(value) do
      render("value_partial.html", type: unquote(key), value: value)
    end
  end

  for key <- @links do
    def render_attribute(unquote(key), %{unquote(key) => value}) when not is_nil(value) do
      render("link_#{unquote(key)}_partial.html", type: unquote(key), value: value)
    end
  end

  def render_attribute(:manager, {uid, name}) do
    render("link_person_partial.html", type: "manager", uid: uid, name: name)
  end

  def render_attribute(:manager, nil), do: nil
  def render_attribute(:direct_reports, []), do: nil

  def render_attribute(:direct_reports, list) when is_list(list) do
    render("list_link_partial.html", type: :direct_reports, value: list)
  end

  def render_attribute(:labeledURI, %{labeledURI: value}) when not is_nil(value) do
    link =
      value
      |> URI.parse()
      |> Map.get(:scheme)
      |> case do
        nil -> "http://" <> value
        _ -> value
      end

    render("link_labeledURI_partial.html", type: :labeledURI, value: link)
  end

  def render_attribute(attr, params) when is_map(params) do
    default_render(attr, Map.get(params, attr))
  end

  def default_render(_, nil), do: nil

  def default_render(attr, value) do
    render("attribute_and_value_partial.html", type: attr, value: value)
  end

  def render_attributes(list, profile) when is_list(list) do
    for attr <- list do
      render_attribute(attr, profile)
    end
    |> Enum.filter(& &1)
  end

  def render_attributes(list, profile) when is_list(list) do
    for attr <- list do
      render_attribute(attr, profile)
    end
    |> Enum.filter(& &1)
  end

  def percent_newer_than(conn, profile) do
    list = conn.assigns.all_employee_start_dates
    count = Enum.count(list)

    remainder =
      list
      |> Enum.drop_while(fn x -> x <= profile.startDate end)
      |> Enum.count()

    Kernel.round(remainder * 100 / count)
  end
end
