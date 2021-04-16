defmodule RobbyWeb.Repo.Migrations.AddNameGameTable do
  use Ecto.Migration

  def change do
    create table(:name_games) do
      add :player_id, :integer
      add :correct_answer, :string
      add :correct_answer_uid, :string
      add :chosen_answer, :string
      add :options, {:array, :string}
    
      timestamps()
    end
  end
end
