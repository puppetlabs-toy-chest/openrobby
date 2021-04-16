defmodule RobbyWeb.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:dn, :string)
      add(:username, :string)
      add(:salt, :string)

      timestamps()
    end
  end
end
