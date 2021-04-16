defmodule RobbyWeb.Repo.Migrations.CreatePasswordPolicy do
  use Ecto.Migration

  def change do
    create table(:password_policies) do
      add :object_class, :string
      add :min_length, :integer
      add :min_char_classes, :integer

      timestamps()
    end

  end
end
