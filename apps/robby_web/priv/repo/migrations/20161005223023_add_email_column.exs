defmodule RobbyWeb.Repo.Migrations.AddEmailColumn do
  use Ecto.Migration

  def change do
    rename(table(:users), :username, to: :email)

    alter table(:users) do
      add(:username, :text)
    end
  end
end
