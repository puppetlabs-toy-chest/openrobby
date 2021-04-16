defmodule RobbyWeb.SettingsProfileView do
  use RobbyWeb.Web, :view

  @lists [:projects, :skills, :sshPublicKey, :languages]
  @unwritable [
    :uid,
    :cn,
    :title,
    :ou,
    :manager,
    :hasSubordinates,
    :st,
    :l,
    :countryName,
    :stateOrProvincename,
    :mail
  ]

  def render_inputs(form, list, profile) when is_list(list) do
    for att <- list do
      render_input(form, att, Map.get(profile, att))
    end
    |> Enum.filter(& &1)
  end

  for att <- @unwritable do
    def render_input(_form, unquote(att), value) do
      RobbyWeb.ProfileView.render_attribute(unquote(att), %{unquote(att) => value})
    end
  end

  for att <- @lists do
    def render_input(form, unquote(att), nil), do: render_input(form, unquote(att), [])

    def render_input(form, unquote(att), value) do
      render(__MODULE__, "list_input_partial.html",
        form: form,
        attribute: unquote(att),
        value: value
      )
    end
  end

  def render_input(form, attribute, value) when not is_nil(value) do
    render(__MODULE__, "input_partial.html", form: form, attribute: attribute, value: value)
  end

  def render_input(form, attribute, nil) do
    render(__MODULE__, "input_partial.html", form: form, attribute: attribute)
  end
end
