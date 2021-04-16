defmodule RobbyWeb.PasswordPolicy do
  use RobbyWeb.Web, :model

  schema "password_policies" do
    field(:object_class, :string)
    field(:min_length, :integer)
    field(:min_char_classes, :integer)

    timestamps()
  end

  @required_fields [:object_class, :min_length, :min_char_classes]
  @optional_fields []

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

  def max_effective_policy([]), do: %RobbyWeb.PasswordPolicy{min_length: 0, min_char_classes: 0}

  def max_effective_policy(policies) do
    length_policy = Enum.max_by(policies, fn policy -> policy.min_length end)
    char_policy = Enum.max_by(policies, fn policy -> policy.min_char_classes end)

    %RobbyWeb.PasswordPolicy{
      min_length: length_policy.min_length,
      min_char_classes: char_policy.min_char_classes
    }
  end

  def passes?(policy, password) do
    cond do
      String.length(password) < policy.min_length -> {:error, :too_short}
      num_char_classes(password) < policy.min_char_classes -> {:error, :too_simple}
      unprintable?(password) -> {:error, :not_printable}
      true -> :ok
    end
  end

  def num_char_classes(password) do
    [:has_upper?, :has_lower?, :has_digit?, :has_punct?, :has_space?]
    |> Enum.map(&apply(__MODULE__, &1, [password]))
    |> Enum.count(& &1)
  end

  def has_upper?(password), do: Regex.match?(~r/[[:upper:]]/u, password)
  def has_lower?(password), do: Regex.match?(~r/[[:lower:]]/u, password)
  def has_digit?(password), do: Regex.match?(~r/[[:digit:]]/u, password)
  def has_punct?(password), do: Regex.match?(~r/[[:punct:]]/u, password)
  def has_space?(password), do: Regex.match?(~r/[[:space:]]/u, password)
  def unprintable?(password), do: !String.printable?(password)
end
